# # Debug
# ? "Using unixtime: " + unixtime()
# ? "Using epochtime: " + epochtime(date(), time())

func unixtime()
	# Get the detailed date and time information from the system
	aTime = TimeList()

	# Extract the necessary components from the list
	year   = aTime[19]  # Full year (e.g., 2025)
	month  = aTime[10]  # Month of the year (1-12)
	day    = aTime[6]   # Day of the month (1-31)
	hour   = aTime[7]   # Hour (0-23)
	minute = aTime[11]  # Minutes after hour (0-59)
	second = aTime[13]  # Seconds after the hour (0-59)

	# Define the number of days in each month for a non-leap year
	daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

	# Calculate the total number of full days passed since the epoch 
	totalDays = 0

	# Add days for all the full years between 1970 and the current year
	for y = 1970 to year - 1
		totalDays += 365
		# isLeapYear check
		if isLeapYear(y)
			totalDays += 1
		ok
	next

	# Add days for all the full months passed in the current year
	for m = 1 to month - 1
		totalDays += daysInMonth[m]
	next

	# If the current year is a leap year and we are past February, add a day
	if month > 2 and isLeapYear(year)
		totalDays += 1
	ok

	# Add the days from the current month (minus one, as it's not a full day yet)
	totalDays += (day - 1)

	# Calculate the total seconds 

	# Convert the total full days to seconds (1 day = 86400 seconds)
	totalSeconds = totalDays * 86400

	# Add the seconds from the current day
	totalSeconds += hour * 3600
	totalSeconds += minute * 60
	totalSeconds += second

	return totalSeconds