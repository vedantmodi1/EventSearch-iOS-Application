# EventSearch-iOS-Application

Built an Ticket Master event search iOS application with the Model-View-Controller design pattern. The Client side was built using Swift language, iOS SDK, and Xcode. Backend is hosted on GCP.

User can search events based on event keywords, distance from their location, category, location and a checkbox to auto-detect location. Used the ipinfo.io API to fetch the user’s geolocation if the location checkbox is checked. If the Location information is used to get events results, client JavaScript used the input address to get the geocoding via the Google Maps Geocoding API. Used the latitude and longitude of the location to construct a RESTful web service URL to retrieve matching search results. Used DOM to display cards for event details and venue details after clicking on the event name and venue details.
