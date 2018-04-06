This folder contains Metrics for the Origin-Destination with Middle Filter(s) trips between the Zones of the named Project.

TERMS
==================================================
Origin Zone: For this Project, trips were analyzed that started in or initially passed through any of the Origin Zones.

Middle Filter Zone: For the Project, trips were analyzed that went through any of the Middle Filter Zones after starting in or passing through an Origin Zone and before ending in or passing through a Destination Zone.

Destination Zone: For the Project, trips were analyzed that ended in or passed through any of the Destination Zones after starting in or passing through an Origin Zone and then passing through a Middle Filter Zone.

Pass-Through: A value set on a Zone indicating how to analyze the trips touching that Zone. Analysis done on a Zone that is marked as pass-through uses the trips that pass through the Zone but do not start or stop in it. This is used mostly for road segments. Analysis on a Zone that is not marked as pass-through uses the trips that start or stop in the Zone. This Zone is often referred to as an “area zone”.

Zone Direction: A pass-through Zone may optionally have a direction which limits the trips analyzed for the Zone: only trips that pass through the zone within -20/+20 degrees of the Direction will be analyzed for the Zone. Values are provided in degrees from 0 to 359, where 0 is due north, 90 is east, 180 is due south, etc. A value of "Null" refers to no direction filter and therefore all trips that pass through the Zone will be used.

FILES
==================================================
Project_OD_MF.txt
=================
This file lists information about the Project as a whole, including the full Project name, organization and user name that created the Project, and the Data Period for the Project.

zones.csv
=========
This file contains information about the Zones used in this Project.
The fields are:

- Zone Type: Indicates if the Zone is an Origin, Middle Filter, or Destination Zone for this Project.
- Zone ID: Numeric ID for the Zone as provided by the user.
- Zone Name: Name for the Zone as provided by the user.
- Zone is Pass-Through: Indicates if the Zone is pass-through or not as described above in the Terms. Values are “Yes” or “No”.
- Zone Direction (degrees): This refers to the direction in which trips pass through the Zone as described above in the Terms.

mf_personal.csv & mf_commercial.csv
===================================
These files contain the OD Metrics for Personal or Commercial trips.
The fields are:

- Device Type: Type of vehicle analyzed with values of “Personal” or “Commercial”.
- Origin Zone ID: Numeric ID for the Origin Zone as provided by the user.
- Origin Zone Name: Name for the Origin Zone as provided by the user.
- Origin Zone Is Pass-Through: Indicates if the Origin Zone is pass-through or not as described above in the Terms. Values are “Yes” or “No”.
- Origin Zone Direction (degrees): This refers to the direction in which trips pass through the Origin Zone as described above in the Terms.
- Middle Filter Zone ID: Numeric ID for the Middle Filter Zone as provided by the user.
- Middle Filter Zone Name: Name for the Middle Filter Zone as provided by the user.
- Middle Filter Zone Direction (degrees): This refers to the direction in which trips pass-through the Middle Filter Zone as described above in the Terms. Note, Middle Filter Zones are always pass-through Zones.
- Destination Zone ID: Numeric ID for the Destination Zone as provided by the user.
- Destination Zone Name: Name for the Destination Zone as provided by the user.
- Destination Zone Is Pass-Through: Indicates if the Destination Zone is pass-through or not as described above in the Terms. Values are “Yes” or “No”.
- Destination Zone Direction (degrees): This refers to the direction in which trips pass through the Destination Zone as described above in the Terms.
- Day Type: Average Day (average of traffic Monday through Sunday), Average Weekday (average of weekday traffic as defined by user), or Average Weekend Day (average of weekend traffic as defined by user).
- Day Part: Segments of the day defined by the user in intervals of hours to analyze traffic (All Day is always included as entire 24 hours). The Day Parts reflect the local time at the Origin Zone.
- O-M-D Traffic (StL Index): StreetLight Trip Index value representing the volume of trips from the Origin Zone, through the Middle Filter Zone, to the Destination Zone.
- Origin Zone Traffic (StL Index): StreetLight Trip Index value representing all trips from the Origin Zone with no limitation on where they went.
- Middle Filter Zone Traffic (StL Index): StreetLight Trip Index value representing all trips through the Middle Filter Zone with no limitation on where they came from or where they went.
- Destination Zone Traffic (StL Index): StreetLight Trip Index value representing all trips to the Destination Zone with no limitation on where they came from.
- Avg Trip Duration (sec): Average time (in seconds) for the trips from the Origin Zone to the Destination Zone. Avg Trip Duration can sometimes have an N/A value when the Origin Zone and Destination Zone are the same or overlapping or when all the intersecting trips fail StreetLight's data quality checks for trip duration.

zone_traffic_mf_personal.csv &
zone_traffic_mf_commercial.csv
==============================
These files contain information about each Zone used in the Project. The StreetLight Trip Index represents all trips appropriate to each Zone with no limitations on where they came or where they went.
The fields are:

- Device Type: Type of vehicle analyzed with values of “Personal” or “Commercial”.
- Zone Type: Indicates if the Zone is an Origin, Middle Filter, or Destination Zone for this Project.
- Zone ID: Numeric ID for the Zone as provided by the user.
- Zone Name: Name for the Zone as provided by the user.
- Zone Is Pass-Through: Indicates if the Zone is pass-through or not as described above in the Terms. Values are “Yes” or “No”.
- Zone Direction (degrees): This refers to the direction in which trips pass through the Zone as described above in the Terms.
- Day Type: Average Day (average of traffic Monday through Sunday), Average Weekday (average of weekday traffic as defined by user), or Average Weekend Day (average of weekend traffic as defined by user).
- Day Part: Segments of the day defined by the user in intervals of hours to analyze traffic (All Day is always included as entire 24 hours). The Day Parts reflect the local time at the Zone.
- Zone Traffic (StL Index): StreetLight Trip Index value representing all trips starting in, passing through, or ending in the Zone based on the Zone Type and the Zone Is Pass Through values.
If the Zone is a pass-through Zone, then the Zone Trip Index is for all trips passing through the Zone. Otherwise, the Zone Trip Index represents the trips starting in Origin Zones or ending in Destination Zones.

*_zone_set.(dbf|prj|shp|shx)
============================
These files comprise the shapefiles for the Project's Zone Sets.

A shapefile consists of the following several files:
.shp file contains the feature geometries and can be viewed in a geographic information systems application such as QGIS.
.dbf file contains the attributes in dBase format and can be opened in Microsoft Excel.
.shx file contains the data index.
.prj file contains the projection information.

These shapefiles have the following attributes/columns:
- id: Numeric ID for the Zone as provided by the user.  This may be null as the field is optional.
- name: Name for the Zone as provided by the user.
- direction (degrees): This refers to the direction in which trips pass through the Zone as described above in the Terms.
- is_pass: Indicates if the Zone is pass-through or not as described above in the Terms. 1 = “Yes” and 0 = “No”.
- geom: Polygon of the Zone.


NOTES
==================================================
OD Pairs with No Values
=======================
If the StreetLight Trip Index values for an OD pair and Middle Filter combination for a specific time period (e.g. Average Weekday, Early AM) are below StreetLight's significance threshold, no results will be shown in the mf_personal.csv and mf_commercial.csv files.
Day Part Calculations
=====================
The Day Part calculations are done in relation to the Zones used in the analysis. The O-M-D Traffic values Day Parts are calculated in relation to the Middle Filter Zone. The Day Part is determined by when Trips pass by the centroid of the Middle Filter Zone.
The Origin Zone Traffic values Day Parts are calculated in relation to the Origin Zone. The Day Part is determined by when Trips either Start in the Origin Zone or pass by the centroid of the Origin Zone, if the Origin Zone is designated as pass-through.
The Middle Filter Zone Traffic values Day Parts are calculated in relation to the Middle Filter Zone. The Day Part is determined by when Trips pass by the centroid of the Middle Filter Zone.
The Destination Zone Traffic values Day Parts are calculated in relation to the Destination Zone. The Day Part is determined by when Trips either end in the Destination Zone or pass by the centroid of the Destination Zone, if the Destination Zone is designated as pass-through.
StreetLight Trip Indices
========================
The StreetLight Trip Index represents trip activity but does not indicate actual number of trips or vehicles. The values are provided on an index. Personal and Commercial values use different indices. Projects in the US and Projects in Canada also use different indices.
For US Projects, the value is normalized by adjusting the number of trips in our data sample to the actual number of trips on a region around Sacramento CA, as derived from the measurements published by the California Department of Transportation. This allows us to capture monthly and seasonal variation more accurately, even as our sample grows.
For Canadian Projects, a value of 500,000 on each index corresponds to average daily traffic on a stretch of Highway 401 east of Toronto.

Comparing StreetLight Trip Indices
==================================
The StreetLight Trip Index values for each vehicle type, weight class, and country are based on different sample populations and therefore cannot be compared with each other. Even though all of the Commercial weight classes use the same index, their StreetLight Trip Index values cannot be compared with each other. StreetLight Data has updated its approach to calculating the StreetLight Trip Index for Projects run after April 5, 2016. Index values for projects run before that date are not comparable to those run after that date. To update the index values for Projects run before that date, or if there are any questions, please contact support@streetlightdata.com.

Trip Type
=========
The file Project.txt specifies the type of Trips used in the analysis: Locked to Route Trips or Unlocked Trips. Unlocked Trips may not consistently align with roads depending upon the Device Ping Rate for Trips, the speed of the vehicle, and how curvy the roads are. Locked to Route Trips address this by aligning to the road segments of the most likely path taken for the set of points that comprise the Unlocked Trip.

Copyright © 2011 - 2017, StreetLight Data, Inc. All rights reserved.