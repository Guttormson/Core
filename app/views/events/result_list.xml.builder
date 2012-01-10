# TODO-RWP Move into separate view files
if @version === '3.0' then

	# TODO-RWP Indicate whether complete or not
	xml.ResultList(
		:xmlns => "http://www.orienteering.org/datastandard/3.0",
		:'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
		:iofVersion => "3.0",
		:createTime => Time.zone.now.iso8601,
		:creator => "WhyJustRun"
		) do
		# TODO-RWP Event classification list
		# TODO-RWP How to do Event Races?
		xml.Event do
			xml.Name @event.name
			xml.StartTime do
				xml.Date @event.local_date.strftime('%F')
				xml.Time @event.local_date.strftime('%T') + @event.local_date.formatted_offset
	    end
	    
	    @event.courses.each { |course|
	    	xml.Class(:idref => course.id)
	    }
		end
		
		involved_clubs = Set.new
		
		@event.courses.each { |course|
			xml.comment! course.name + " entries"
			xml.ClassResult do
				xml.Class(:idref => course.id)
				
				xml.Course do
					xml.Length course.distance unless course.distance.nil?
					xml.Climb course.climb unless course.climb.nil?
				end
				
				i = 1
				course.sorted_results.each { |result|
					xml.PersonResult do
						user = result.user
						xml.Person do
							xml.Id user.id
							xml.Name do
								xml.Given user.first_name
								xml.Family user.last_name
							end
						end
						
						unless user.club.nil? then
							xml.Organization(:idref => user.club.id)
							involved_clubs << user.club
						end
						
						xml.Result do
							unless result.time.nil? then
								# Can't say the start time or end time cause we don't know :(
								hours = result.time.hour.to_i
								minutes = result.time.min.to_i
								seconds = result.time.sec.to_i
								xml.Time hours * 3600 + minutes * 60 + seconds
							end
							if result.status == :ok then
								xml.Position i
							end
							# TODO-RWP Once the CakePHP site uses IOF Status xml.Status result.iof_status
						end
					end
					
					i += 1
				}
			end
		}
		
		xml.References do
			@event.courses.each { |course|
				xml.Class do
					xml.Id course.id
					xml.Name course.name
				end
			}
			
			involved_clubs.each { |club|
				xml.Organization do
					xml.Id club.id
					xml.Name club.name
				end
			}
		end
	end

elsif @version == '2.0.3' then

	xml.instruct!
	xml.declare! :DOCTYPE, :ResultList, :SYSTEM, "IOFdata.dtd"
	xml.ResultList do
		# TODO-RWP Event classification list
		# TODO-RWP How to do Event Races?
		xml.EventId @event.id
		@event.courses.each { |course|
			xml.ClassResult do
				xml.ClassShortName course.name
				i = 1
				course.sorted_results.each { |result|
					xml.PersonResult do
						xml.Person do
							xml.PersonName do
								xml.Given result.user.first_name
								xml.Family result.user.last_name
							end
							
							xml.PersonId result.user.id
						end
						
						xml.Result do
							unless result.time.nil? then
								xml.Time result.time.strftime('%H:%M:%S')
								# TODO-RWP Should be a boolean
								if result.status == :ok then
									xml.ResultPosition i
								end
							end
							
							# TODO-RWP Once the CakePHP site uses IOF Status xml.CompetitorStatus(:value => result.iof_status)
							# TODO-RWP Splits
						end
					end
					i += 1
				}
			end
		}
	end
end


