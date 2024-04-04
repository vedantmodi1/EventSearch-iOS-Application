//
//  ContentView.swift
//  homework9
//
//  Created by Vedant Modi on 4/16/23.
//

import SwiftUI
import Foundation
import Kingfisher
import Alamofire
import UIKit
import MapKit
import Combine
import Toast

struct EventStruct: Identifiable, Hashable {
    var id: String
    var name: String
    var imageUrl: String
    var date: String
    var time: String
    var venue: String
    var genre: String
}

struct selectedEventStruct: Identifiable, Hashable {
    var id: String
    var name: String
    var artistUrl: String
    var date: String
    var time: String
    var genre: String
    var priceRange: String
    var ticketStatus: String
    var buyTicketUrl: String
    var seatMap: String
    var artists: String
    var venues: String
}

struct selectedSpotifyStruct: Identifiable, Hashable {
    var isArtist: Bool
    var id: String
    var name: String
    var image: String
    var followers: String
    var popularity: String
    var link: String
    var albumImages: [String]
}

struct artistsStruct: Hashable {
    var name: [String]
}

struct selectedVenueStruct: Hashable {
    var name: String
    var address: String
    var phone: String
    var open_hours: String
    var gen_rule: String
    var child_rule: String
    var id: String
}

struct selectedVenueLocationStruct: Identifiable {
    var id = UUID()
    var name: String
    var coordinates: CLLocationCoordinate2D
}

struct FavData: Codable {
    let id: String
    let date: String
    let event: String
    let category: String
    let venue: String
}

var eventData: [EventStruct] = []
var sortedEventData: [EventStruct] = []
var selectedEventData: [selectedEventStruct] = []
var selectedSpotifyData: [selectedSpotifyStruct] = []
var artistsToSearch: [artistsStruct] = []
var selectedVenueData: [selectedVenueStruct] = []
var selectedVenueLocation: [selectedVenueLocationStruct] = []
//var musicArtists: [String] = []

struct FavsView: View {
    @State var favDataList: [FavData] = []
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Group {
                if favDataList.isEmpty {
                    Text("No favorites found")
                        .foregroundColor(Color.red)
                } else {
                    List {
                        ForEach(favDataList, id: \.id) { favdata in
                            HStack {
                                Section {
                                    Text(favdata.date)
                                        .font(.footnote)
                                    Text(favdata.event)
                                        .font(.footnote)
                                    Text(favdata.category)
                                        .font(.footnote)
                                    Text(favdata.venue)
                                        .font(.footnote)
                                }
                            }
                            .swipeActions(allowsFullSwipe: true) {
                                Button {
                                    deleteRecord(with: favdata.id)
                                    UIApplication.shared.windows.first?.rootViewController?.view.makeToast("Removed from favorites.", duration: 3.0, position: .bottom)
                                } label: {
                                    Text("Delete")
                                        .foregroundColor(.white)
                                        .background(Color.red)
                                }
                                .background(Color.red)
                            }
                        }
                    }
                }
            }
            .onAppear {
                let allKeys = UserDefaults.standard.dictionaryRepresentation().keys
                for key in allKeys {
                    if let data = UserDefaults.standard.data(forKey: key) {
                        let decoder = JSONDecoder()
                        if let decodedData = try? decoder.decode(FavData.self, from: data) {
                            favDataList.append(decodedData)
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true) // hide the default back button
        .navigationBarItems(leading:
            Button(action: {
                // Navigate back to the previous view
                // (assuming it was also a NavigationView)
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Image(systemName: "chevron.left")
                Text("Event Search")
            })
        )
    }
    
    func deleteRecord(with id: String) {
        //Deelete record here
        UserDefaults.standard.removeObject(forKey: id)
        if let index = favDataList.firstIndex(where: { $0.id == id }) {
            favDataList.remove(at: index)
        }
    }
}

struct EventView: View {
    var eventId: String
    @State var displaySelectedEventData: Bool = false
    @State var displaySelectedSpotifyData: Bool = false
    @State var displaySelectedVenueData: Bool = false
    @State var showSpotify: Bool = false
    @State var musicArtists: [String] = []
    @State var callSpotify: Bool = false
    @State var count: Int = 0
    //musicArtists = []
    @State private var selectedTab = 0
    @State var eventIsFav: Bool = false
    @Environment(\.presentationMode) var presentationMode
    
    @State var coordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
    
    @State var showMap: Bool = false
    
    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                ScrollView {
                    VStack {
                        if (displaySelectedEventData) {
                            
                            HStack {
                                Text(selectedEventData[0].name)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .multilineTextAlignment(.center)
                            }
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Date")
                                        .fontWeight(.semibold)
                                    Text(selectedEventData[0].date)
                                        .foregroundColor(Color.gray)
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("Artist | Team")
                                        .fontWeight(.semibold)
                                    Text(selectedEventData[0].artists)
                                        .foregroundColor(Color.gray)
                                        .multilineTextAlignment(.trailing)
                                }
                            }
                            .padding()
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Venue")
                                        .fontWeight(.semibold)
                                    Text(selectedEventData[0].venues)
                                        .foregroundColor(Color.gray)
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("Genre")
                                        .fontWeight(.semibold)
                                    Text(selectedEventData[0].genre)
                                        .foregroundColor(Color.gray)
                                        .multilineTextAlignment(.trailing)
                                }
                            }
                            .padding()
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Price Range")
                                        .fontWeight(.semibold)
                                    Text(selectedEventData[0].priceRange)
                                        .foregroundColor(Color.gray)
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("Ticket Status")
                                        .fontWeight(.semibold)
                                    if (selectedEventData[0].ticketStatus == "onsale") {
                                        Text("On Sale")
                                            .foregroundColor(.white)
                                            .padding(10)
                                            .background(Color.green)
                                            .cornerRadius(10)
                                    } else if (selectedEventData[0].ticketStatus == "offsale") {
                                        Text("Off Sale")
                                            .foregroundColor(.white)
                                            .padding(10)
                                            .background(Color.red)
                                            .cornerRadius(10)
                                    } else if (selectedEventData[0].ticketStatus == "canceled") {
                                        Text("Canceled")
                                            .foregroundColor(.white)
                                            .padding(10)
                                            .background(Color.black)
                                            .cornerRadius(10)
                                    } else if (selectedEventData[0].ticketStatus == "postponed") {
                                        Text("Postponed")
                                            .foregroundColor(.white)
                                            .padding(10)
                                            .background(Color.orange)
                                            .cornerRadius(10)
                                    } else if (selectedEventData[0].ticketStatus == "rescheduled") {
                                        Text("Rescheduled")
                                            .foregroundColor(.white)
                                            .padding(10)
                                            .background(Color.orange)
                                            .cornerRadius(10)
                                    }
                                }
                            }
                            .padding()
                            
                            if (eventIsFav) {
                                Button(action: {
                                    saveEvent()
                                    UIApplication.shared.windows.first?.rootViewController?.view.makeToast("Removed from favorites.", duration: 3.0, position: .bottom)
                                    
                                }) {
                                    Text("Remove Favorite")
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.red)
                                        .cornerRadius(10)
                                }
                            } else {
                                Button(action: {
                                    saveEvent()
                                    UIApplication.shared.windows.first?.rootViewController?.view.makeToast("Added to favorites.", duration: 3.0, position: .bottom)
                                }) {
                                    Text("Save Event")
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.blue)
                                        .cornerRadius(10)
                                }
                            }
                            
                            KFImage(URL(string: selectedEventData[0].seatMap))
                                .resizable()
                                .frame(width: 200, height: 200)
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(4)
                            
                            HStack {
                                Text("Buy Ticket At: ")
                                    .fontWeight(.semibold)
                                
                                Link("Ticketmaster", destination: URL(string: selectedEventData[0].buyTicketUrl)!)
                                
                            }
                            .padding()
                            
                            HStack(alignment: .center) {
                                Text("Share on: ")
                                    .fontWeight(.semibold)
                                
                                let twitterUrl = "http://twitter.com/share?text=\(selectedEventData[0].name)&url=\(selectedEventData[0].buyTicketUrl)"
                                let twitterUrl1 = twitterUrl.replacingOccurrences(of: " ", with: "%20")
                                
                                KFImage(URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6f/Logo_of_Twitter.svg/1024px-Logo_of_Twitter.svg.png"))
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .aspectRatio(contentMode: .fit)
                                    .cornerRadius(2)
                                    .onTapGesture {
                                        if let twitterUrl2 = URL(string: twitterUrl1) {
                                            UIApplication.shared.open(twitterUrl2)
                                        }
                                    }
                                
                                let fbUrl = "https://www.facebook.com/sharer/sharer.php?u=\(selectedEventData[0].buyTicketUrl)&amp;src=sdkpreparse"
                                
                                KFImage(URL(string: "https://upload.wikimedia.org/wikipedia/commons/0/05/Facebook_Logo_%282019%29.png"))
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .aspectRatio(contentMode: .fit)
                                    .cornerRadius(2)
                                    .onTapGesture {
                                        if let fbUrl1 = URL(string: fbUrl) {
                                            UIApplication.shared.open(fbUrl1)
                                        }
                                    }
                            }
                            .padding()
                            
                        } else {
                            VStack {
                                ProgressView()
                                    .onAppear {
                                        fetchEventData()
                                    }
                                Text("Please wait...")
                                    .foregroundColor(Color.gray)
                            }
                        }
                        
                    }
                }
                .tabItem {
                    Label("Events", systemImage: "text.bubble.fill")
                }
                .tag(0)
                
                ScrollView {
                    VStack {
                        if displaySelectedSpotifyData {
                            if (selectedSpotifyData[0].isArtist == false) {
                                Text("No music related artist details to show")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .padding()
                            }
                            else {
                                ForEach(selectedSpotifyData, id: \.self)
                                { selectedSpotifyDataElem in
                                    VStack {
                                        //Text(selectedSpotifyData[0].link)
                                        //Text(selectedSpotifyData[0].name)
                                        HStack {
                                            KFImage(URL(string: selectedSpotifyDataElem.image))
                                                .resizable()
                                                .frame(width: 100, height: 100)
                                                .aspectRatio(contentMode: .fit)
                                                .cornerRadius(4)
                                            VStack(alignment: .leading) {
                                                Text(selectedSpotifyDataElem.name)
                                                    .font(.title2)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(Color.white)
                                                    .multilineTextAlignment(.leading)
                                                //.multilineTextAlignment(.leading)
                                                Spacer()
                                                HStack {
                                                    if (Int(selectedSpotifyDataElem.followers)! > 999999) {
                                                        let digitCount = selectedSpotifyDataElem.followers.count - 6
                                                        let pop = String(selectedSpotifyDataElem.followers.prefix(digitCount))
                                                        Text("\(pop)M")
                                                            .fontWeight(.semibold)
                                                            .foregroundColor(Color.white)
                                                            .multilineTextAlignment(.leading)
                                                    } else if (Int(selectedSpotifyDataElem.followers)! > 999) {
                                                        let digitCount = selectedSpotifyDataElem.followers.count - 3
                                                        let pop = String(selectedSpotifyDataElem.followers.prefix(digitCount))
                                                        Text("\(pop)K")
                                                            .fontWeight(.semibold)
                                                            .foregroundColor(Color.white)
                                                            .multilineTextAlignment(.leading)
                                                    }
                                                    Text("Followers")
                                                        .foregroundColor(Color.white)
                                                }
                                                Spacer()
                                                
                                                let spotUrl = selectedSpotifyDataElem.link
                                                
                                                KFImage(URL(string: "https://storage.googleapis.com/pr-newsroom-wp/1/2018/11/Spotify_Logo_CMYK_Green.png"))
                                                    .resizable()
                                                    .frame(width: 80, height: 30)
                                                    .aspectRatio(contentMode: .fit)
                                                    .cornerRadius(2)
                                                    .onTapGesture {
                                                        if let spotUrl1 = URL(string: spotUrl) {
                                                            UIApplication.shared.open(spotUrl1)
                                                        }
                                                    }
                                                
                                            }
                                            VStack{
                                                Text("Popularity")
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(Color.white)
                                                ZStack {
                                                    Text(selectedSpotifyDataElem.popularity)
                                                        .foregroundColor(Color.white)
                                                    Circle()
                                                        .stroke(
                                                            Color.orange.opacity(0.5),
                                                            lineWidth: 10
                                                        )
                                                        .frame(width: 60, height: 60)
                                                    Circle()
                                                        .trim(from: 0, to: Double(selectedSpotifyDataElem.popularity)!/100)
                                                        .stroke(
                                                            Color.orange,
                                                            lineWidth: 10
                                                        )
                                                    // 1
                                                        .rotationEffect(.degrees(-90))
                                                        .frame(width: 60, height: 60)
                                                }
                                            }
                                        }
                                        .padding()
                                        
                                        VStack(alignment: .leading) {
                                            Text("Popular Albums")
                                                .font(.title2)
                                                .fontWeight(.bold)
                                                .foregroundColor(Color.white)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding()
                                        }
                                        
                                        HStack {
                                            KFImage(URL(string: selectedSpotifyDataElem.albumImages[0]))
                                                .resizable()
                                                .frame(width: 85, height: 85)
                                                .aspectRatio(contentMode: .fit)
                                                .cornerRadius(4)
                                            Spacer()
                                            KFImage(URL(string: selectedSpotifyDataElem.albumImages[1]))
                                                .resizable()
                                                .frame(width: 85, height: 85)
                                                .aspectRatio(contentMode: .fit)
                                                .cornerRadius(4)
                                            Spacer()
                                            KFImage(URL(string: selectedSpotifyDataElem.albumImages[2]))
                                                .resizable()
                                                .frame(width: 85, height: 85)
                                                .aspectRatio(contentMode: .fit)
                                                .cornerRadius(4)
                                        }
                                        .padding([.leading, .bottom, .trailing])
                                    }
                                    .background(
                                        Rectangle()
                                            .foregroundColor(Color(red: 0.294, green: 0.298, blue: 0.298))
                                            .cornerRadius(8)
                                        //.shadow(radius: 4)
                                    )
                                    .padding()
                                    //.background(Color.gray.opacity(0.2))
                                    Spacer()
                                }
                            }
                        } else {
                            VStack {
                                ProgressView()
                                    .onAppear {
                                        fetchSpotifyData()
                                    }
                                Text("Please wait...")
                                    .foregroundColor(Color.gray)
                            }
                        }
                    }
                }
                .tabItem {
                    Label("Artist/Team", systemImage: "guitars.fill")
                }
                .tag(1)
                
                //ScrollView {
                    VStack {
                        if displaySelectedVenueData {
                            HStack {
                                Text(selectedEventData[0].name)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                            HStack{
                                VStack{
                                    Text("Name")
                                        .fontWeight(.semibold)
                                    Text(selectedVenueData[0].name)
                                        .foregroundColor(Color.gray)
                                        .multilineTextAlignment(.center)
                                }
                            }
                            .padding()
                            if (selectedVenueData[0].address != " ")
                            {
                                HStack{
                                    VStack{
                                        Text("Address")
                                            .fontWeight(.semibold)
                                        Text(selectedVenueData[0].address)
                                            .foregroundColor(Color.gray)
                                            .multilineTextAlignment(.center)
                                    }
                                }
                                .padding()
                            }
                            if (selectedVenueData[0].phone != " ")
                            {
                                HStack{
                                    VStack{
                                        Text("Phone Number")
                                            .fontWeight(.semibold)
                                        Text(selectedVenueData[0].phone)
                                            .foregroundColor(Color.gray)
                                    }
                                }
                                .padding()
                            }
                            if (selectedVenueData[0].open_hours != " ")
                            {
                                HStack{
                                    VStack{
                                        Text("Open Hours")
                                            .fontWeight(.semibold)
                                        ScrollView(.vertical) {
                                            Text(selectedVenueData[0].open_hours)
                                                .foregroundColor(Color.gray)
                                                .lineLimit(nil)
                                                .frame(maxWidth: .infinity)
                                                .frame(maxHeight: 90)
                                        }
                                    }
                                }
                                .padding()
                            }
                            if (selectedVenueData[0].gen_rule != " ")
                            {
                                HStack{
                                    VStack{
                                        Text("General Rule")
                                            .fontWeight(.semibold)
                                        ScrollView(.vertical) {
                                        Text(selectedVenueData[0].gen_rule)
                                            .foregroundColor(Color.gray)
                                            .lineLimit(nil)
                                            .frame(maxWidth: .infinity)
                                            .frame(maxHeight: 90)
                                        }
                                    }
                                }
                                .padding()
                            }
                            if (selectedVenueData[0].child_rule != " ")
                            {
                                HStack{
                                    VStack{
                                        Text("Child Rule")
                                            .fontWeight(.semibold)
                                        ScrollView(.vertical) {
                                        Text(selectedVenueData[0].child_rule)
                                            .foregroundColor(Color.gray)
                                            .lineLimit(nil)
                                            .frame(maxWidth: .infinity)
                                            .frame(maxHeight: 90)
                                        }
                                    }
                                }
                                .padding()
                            }
                            Button(action: {
                                mapDisplay(venueName4Loc: selectedVenueData[0].name)
                                //showMap = true
                            }) {
                                Text("Show venue on maps")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.red)
                                    .cornerRadius(10)
                            }
                            /*.sheet(isPresented: $showMap, onDismiss: {
                             print("dismiss")
                             showMap = false
                             }) {
                             Map(coordinateRegion: $coordinateRegion)s
                             }*/
                        } else {
                            VStack {
                                ProgressView()
                                    .onAppear {
                                        fetchVenueData()
                                    }
                                Text("Please wait...")
                                    .foregroundColor(Color.gray)
                            }
                        }
                    }
                //}
                .tabItem {
                    Label("Venue", systemImage: "location.fill")
                }
                .tag(2)
                
            }
        }
        .navigationBarBackButtonHidden(true) // hide the default back button
        .navigationBarItems(leading:
            Button(action: {
                // Navigate back to the previous view
                // (assuming it was also a NavigationView)
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Image(systemName: "chevron.left")
                Text("Event Search")
            })
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(
            ZStack {
                if showMap {
                    Map(coordinateRegion: $coordinateRegion, annotationItems: selectedVenueLocation) { location in
                        MapMarker(coordinate: location.coordinates)
                    }
                        .transition(.move(edge: .top))
                        .edgesIgnoringSafeArea(.all)
                    
                    Button(action: {
                        showMap = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white)
                            .font(.title)
                    }
                    .padding(.trailing, 15)
                    .padding(.top, 55)
                    .frame(maxWidth: .infinity, alignment: .topTrailing)
                }
            }
        )
    }
    
    //(completion: @escaping () -> Void)
    
    func mapDisplay(venueName4Loc: String) {
        var venueName4Url = venueName4Loc.replacingOccurrences(of: " ", with: "%20")
        var locationUrl = "https://vkmodi571hw8.wl.r.appspot.com/api/venuemap?venuename=" + venueName4Url;

        AF.request(locationUrl).response { response in
            guard let data = response.data else {
                print("Error: No data returned venue2")
                return
            }
            do {
                if let venueLocationJson = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    //print(type(of:selectedVenueJson))
                    
                    guard let venueLocationJsonData = try? JSONSerialization.data(withJSONObject: venueLocationJson, options: []) else {
                        print("Error creating JSON data")
                        return
                    }
                    
                    do {
                        if let parsedVenueLocationJsonData = try JSONSerialization.jsonObject(with: venueLocationJsonData, options: []) as? [String: Any] {
                            
                            selectedVenueLocation.removeAll()
                            
                            var latitude: Double = 0.0
                            do {
                                guard let results = parsedVenueLocationJsonData["results"] as? [[String: Any]],
                                      let geometry = results[0]["geometry"] as? [String: Any],
                                      let location = geometry["location"] as? [String: Any],
                                      let lat = location["lat"] as? Double else {
                                    print("error")
                                    throw NSError(domain: "myDomain", code: 0, userInfo: nil)
                                }
                                latitude = lat
                            } catch {
                                print("ERROR lat")
                            }
                            
                            var longitude: Double = 0.0
                            do {
                                guard let results = parsedVenueLocationJsonData["results"] as? [[String: Any]],
                                      let geometry = results[0]["geometry"] as? [String: Any],
                                      let location = geometry["location"] as? [String: Any],
                                      let long = location["lng"] as? Double else {
                                    print("error")
                                    throw NSError(domain: "myDomain", code: 0, userInfo: nil)
                                }
                                longitude = long
                            } catch {
                                print("ERROR long")
                            }
                            
                            selectedVenueLocation = [selectedVenueLocationStruct(name: venueName4Loc, coordinates: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))]
                            
                            print("LOCATION", selectedVenueLocation)
                            //print(type(of: eventData))
                            //print(selectedEventData[0].id)
                            
                            
                            coordinateRegion = MKCoordinateRegion(
                                center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                                span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
                            print(coordinateRegion)
                            showMap = true
                        }
                        
                    } catch {
                        print("Error parsing JSON: \(error.localizedDescription)")
                    }
                }
                
            } catch let error {
                print("Error: \(error.localizedDescription)")
            }
        }

        
    }
    
    func saveEvent() {
        if let data = UserDefaults.standard.data(forKey: selectedEventData[0].id) {
            let decoder = JSONDecoder()
            if let decodedData = try? decoder.decode(FavData.self, from: data) {
                print(decodedData.event)
                print(decodedData.date)
            }
            UserDefaults.standard.removeObject(forKey: selectedEventData[0].id)
            eventIsFav = false
        } else {
            let data = FavData(id: selectedEventData[0].id, date: selectedEventData[0].date, event: selectedEventData[0].name, category: selectedEventData[0].genre, venue: selectedEventData[0].venues)
            
            let encoder = JSONEncoder()
            guard let encodedData = try? encoder.encode(data) else {
                return
            }
            UserDefaults.standard.set(encodedData, forKey: selectedEventData[0].id)
            eventIsFav = true
        }
    }
    
    func fetchEventData() {
        displaySelectedEventData = false
        //print("reached")
        //print(eventId)
        
        print("REACHED EVENT")
        let eventUrl = URL(string: "https://vkmodi571hw8.wl.r.appspot.com/api/selectedeventdata?eventid=" + eventId)!
        print(eventUrl)
        AF.request(eventUrl).response { response in
            guard let data = response.data else {
                print("Error: No data returned")
                return
            }
            do {
                if let selectedEventJson = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    //print(type(of:selectedEventJson))
                    
                    guard let selectedEventJsonData = try? JSONSerialization.data(withJSONObject: selectedEventJson, options: []) else {
                        print("Error creating JSON data")
                        return
                    }
                    
                    do {
                        if let parsedSelectedEventJsonData = try JSONSerialization.jsonObject(with: selectedEventJsonData, options: []) as? [String: Any] {
                            
                            selectedEventData.removeAll()
                            
                            var selectedEventName = ""
                            do {
                                guard let selectedEventNameTemp = parsedSelectedEventJsonData["name"] as? String else {
                                    throw NSError(domain: "myDomain", code: 0, userInfo: nil)
                                }
                                selectedEventName = selectedEventNameTemp
                            } catch {
                                print("error selectedEventName")
                            }
                            
                            var selectedEventArtistUrl: String = ""
                            do {
                                guard let embedded = parsedSelectedEventJsonData["_embedded"] as? [String: Any],
                                      let attractions = embedded["attractions"] as? [[String: Any]],
                                      let selectedEventArtistUrlTemp = attractions[0]["url"] as? String else {
                                    //print("error")
                                    throw NSError(domain: "myDomain", code: 0, userInfo: nil)
                                }
                                selectedEventArtistUrl = selectedEventArtistUrlTemp
                            } catch {
                                print("error selectedEventArtistUrlTemp")
                            }
                            
                            var selectedEventLocalTime = ""
                            do {
                                guard let dates = parsedSelectedEventJsonData["dates"] as? [String: Any],
                                      let start = dates["start"] as? [String: Any],
                                      var selectedEventLocalTimeTemp = start["localTime"] as? String else {
                                    throw NSError(domain: "myDomain", code: 0, userInfo: nil)
                                }
                                selectedEventLocalTime = selectedEventLocalTimeTemp
                                if selectedEventLocalTime == "undefined" {
                                    selectedEventLocalTime = ""
                                }
                            }
                            catch {
                                print("error selectedEventLocalTimeTemp")
                            }
                            
                            var selectedEventLocalDate = ""
                            do {
                                guard let dates = parsedSelectedEventJsonData["dates"] as? [String: Any],
                                      let start = dates["start"] as? [String: Any],
                                      var selectedEventLocalDateTemp = start["localDate"] as? String else {
                                    throw NSError(domain: "myDomain", code: 0, userInfo: nil)
                                }
                                selectedEventLocalDate = selectedEventLocalDateTemp
                                if selectedEventLocalDate == "undefined" {
                                    selectedEventLocalDate = ""
                                }
                            }
                            
                            var selectedEventGenre1 = ""
                            do {
                                guard let classifications = parsedSelectedEventJsonData["classifications"] as? [[String: Any]],
                                      let subGenre = classifications[0]["subGenre"] as? [String: Any],
                                      let selectedEventGenre1Temp = subGenre["name"] as? String else {
                                        throw NSError(domain: "myDomain", code: 0, userInfo: nil)
                                }
                                selectedEventGenre1 = selectedEventGenre1Temp
                            }
                            catch {
                                print("error selectedEventGenre1")
                            }
                            
                            var selectedEventGenre2 = ""
                            do {
                                    guard let classifications = parsedSelectedEventJsonData["classifications"] as? [[String: Any]],
                                    let genre = classifications[0]["genre"] as? [String: Any],
                                    let selectedEventGenre2Temp = genre["name"] as? String else {
                                        throw NSError(domain: "myDomain", code: 0, userInfo: nil)
                                    }
                                    selectedEventGenre2 = selectedEventGenre2Temp
                            }
                            catch {
                                print("error selectedEventGenre2")
                            }
                            
                            var selectedEventGenre3 = ""
                            do {
                                  guard let classifications = parsedSelectedEventJsonData["classifications"] as? [[String: Any]],
                                  let segment = classifications[0]["segment"] as? [String: Any],
                                  let selectedEventGenre3Temp = segment["name"] as? String else {
                                        throw NSError(domain: "myDomain", code: 0, userInfo: nil)
                                }
                                selectedEventGenre3 = selectedEventGenre3Temp
                            }
                            catch {
                                print("error selectedEventGenre3")
                            }
                            
                            var selectedEventGenre4 = ""
                            do {
                                guard let classifications = parsedSelectedEventJsonData["classifications"] as? [[String: Any]],
                                      let subType = classifications[0]["subType"] as? [String: Any],
                                      let selectedEventGenre4Temp = subType["name"] as? String else {
                                        throw NSError(domain: "myDomain", code: 0, userInfo: nil)
                                }
                                selectedEventGenre4 = selectedEventGenre4Temp
                            }
                            catch {
                                print("error selectedEventGenre4")
                            }
                            
                            var selectedEventGenre5 = ""
                            do {
                                guard let classifications = parsedSelectedEventJsonData["classifications"] as? [[String: Any]],
                                      let type = classifications[0]["type"] as? [String: Any],
                                      let selectedEventGenre5Temp = type["name"] as? String else {
                                    throw NSError(domain: "myDomain", code: 0, userInfo: nil)
                                }
                                selectedEventGenre5 = selectedEventGenre5Temp
                            }
                            catch {
                                print("error selectedEventGenre5")
                            }
                            
                            var selectedEventGenre = ""
                            if (selectedEventGenre1 != "Nan" && selectedEventGenre1 != "Undefined"){
                                selectedEventGenre = selectedEventGenre + selectedEventGenre1 + " | "
                            }
                            if (selectedEventGenre2 != "Nan" && selectedEventGenre2 != "Undefined"){
                                selectedEventGenre = selectedEventGenre + selectedEventGenre2 + " | "
                            }
                            if (selectedEventGenre3 != "Nan" && selectedEventGenre3 != "Undefined"){
                                selectedEventGenre = selectedEventGenre + selectedEventGenre3 + " | "
                            }
                            
                            if (selectedEventGenre4 != "Nan" && selectedEventGenre4 != "Undefined"){
                                selectedEventGenre = selectedEventGenre + selectedEventGenre4 + " | "
                            }
                            if (selectedEventGenre5 != "Nan" && selectedEventGenre5 != "Undefined"){
                                selectedEventGenre = selectedEventGenre + selectedEventGenre5 + " | "
                            }
                            
                            if (selectedEventGenre != "") {
                                selectedEventGenre = String(selectedEventGenre.prefix(selectedEventGenre.count - 3))
                            }
                            
                            var priceRangesMin = ""
                            do {
                                guard let priceRanges = parsedSelectedEventJsonData["priceRanges"] as? [[String: Any]],
                                      let priceRangesMinTemp = priceRanges[0]["min"] as? Int else {
                                    throw NSError(domain: "myDomain", code: 0, userInfo: nil)
                                }
                                priceRangesMin = String(priceRangesMinTemp)
                            }
                            catch {
                                print("error priceRangesMin")
                            }
                            
                            var priceRangesMax = ""
                            do{
                                guard let priceRanges = parsedSelectedEventJsonData["priceRanges"] as? [[String: Any]],
                                      let priceRangesMaxTemp = priceRanges[0]["max"] as? Int else {
                                    throw NSError(domain: "myDomain", code: 0, userInfo: nil)
                                }
                                priceRangesMax = String(priceRangesMaxTemp)
                            }
                            catch {
                                print("error priceRangesMax")
                            }
                            var selectedEventPriceRange = ""
                            
                            var currency = ""
                            do {
                                guard let priceRanges = parsedSelectedEventJsonData["priceRanges"] as? [[String: Any]],
                                      let currencyTemp = priceRanges[0]["currency"] as? String else {
                                    throw NSError(domain: "myDomain", code: 0, userInfo: nil)
                                }
                                currency = currencyTemp
                            }
                            catch {
                                print("error currency")
                            }
                            
                            //selectedEventPriceRange = String(priceRangesMin) + " - " + String(priceRangesMax) + " " + currency
                            selectedEventPriceRange = priceRangesMin + " - " + priceRangesMax + " " + currency
                            
                            var selectedEventTicketStatus = ""
                            do {
                                guard let dates = parsedSelectedEventJsonData["dates"] as? [String: Any],
                                      let status = dates["status"] as? [String: Any],
                                      let selectedEventTicketStatusTemp = status["code"] as? String else {
                                    throw NSError(domain: "myDomain", code: 0, userInfo: nil)
                                }
                                selectedEventTicketStatus = selectedEventTicketStatusTemp
                            }
                            catch {
                                print("error selectedEventTicketStatus")
                            }
                            
                            var selectedEventBuyTicket = ""
                            do {
                                guard let selectedEventBuyTicketTemp = parsedSelectedEventJsonData["url"] as? String else {
                                    throw NSError(domain: "myDomain", code: 0, userInfo: nil)
                                }
                                selectedEventBuyTicket = selectedEventBuyTicketTemp
                            }
                            catch {
                                print("error selectedEventBuyTicket")
                            }
                            
                            var selectedEventSeatMap = ""
                            do {
                                guard let seatmap = parsedSelectedEventJsonData["seatmap"] as? [String: Any],
                                      let selectedEventSeatMapTemp = seatmap["staticUrl"] as? String else {
                                        throw NSError(domain: "myDomain", code: 0, userInfo: nil)
                                }
                                selectedEventSeatMap = selectedEventSeatMapTemp
                            }
                            catch {
                                print("error selectedEventSeatMap")
                            }
                            
                            var selectedEventArtists:String = ""
                            do {
                                guard let embedded = parsedSelectedEventJsonData["_embedded"] as? [String: Any],
                                      let attractionsLen = embedded["attractions"] as? [[String: Any]] else {
                                          throw NSError(domain: "myDomain", code: 0, userInfo: nil)
                                      }
                                for i in 0..<attractionsLen.count {
                                    guard let embedded = parsedSelectedEventJsonData["_embedded"] as? [String: Any],
                                          let attractions = embedded["attractions"] as? [[String: Any]],
                                          let selectedEventArtist = attractions[i]["name"] as? String else {
                                              return
                                          }
                                    selectedEventArtists = selectedEventArtists + selectedEventArtist + " | "
                                }
                            } catch {
                                print("error selectedEventArtists")
                            }

                            
                            if (selectedEventArtists != "") {
                                selectedEventArtists = String(selectedEventArtists.prefix(selectedEventArtists.count - 3))
                            }
                            
                            var venuesLen: [[String: Any]] = []
                            do {
                                guard let embedded = parsedSelectedEventJsonData["_embedded"] as? [String: Any],
                                      let venuesLenTemp = embedded["venues"] as? [[String: Any]] else {
                                    throw NSError(domain: "myDomain", code: 0, userInfo: nil)
                                }
                                venuesLen = venuesLenTemp
                            }
                            catch {
                                print ("error venuesLen")
                            }
                            var selectedEventVenues = ""
                            for i in 0..<venuesLen.count {
                                do {
                                    guard let embedded = parsedSelectedEventJsonData["_embedded"] as? [String: Any],
                                          let venues = embedded["venues"] as? [[String: Any]],
                                          let selectedEventVenue = venues[i]["name"] as? String else {
                                        throw NSError(domain: "myDomain", code: 0, userInfo: nil)
                                    }
                                    selectedEventVenues = selectedEventVenues + selectedEventVenue + " | "
                                }
                                catch {
                                    print("error selectedEventVenues")
                                }
                                
                            }
                            //print("21")
                            if (selectedEventVenues != "") {
                                selectedEventVenues = String(selectedEventVenues.prefix(selectedEventVenues.count - 3))
                            }
                            
                            let selectedEventDataTemp = selectedEventStruct(id: eventId, name: selectedEventName, artistUrl: selectedEventArtistUrl, date: selectedEventLocalDate, time: selectedEventLocalTime, genre: selectedEventGenre, priceRange: selectedEventPriceRange, ticketStatus: selectedEventTicketStatus, buyTicketUrl: selectedEventBuyTicket, seatMap: selectedEventSeatMap, artists: selectedEventArtists, venues: selectedEventVenues)
                            
                            selectedEventData.append(selectedEventDataTemp)
                            print("EVENT", selectedEventData)
                            //print(type(of: eventData))
                            //print(selectedEventData[0].id)
                            if let data = UserDefaults.standard.data(forKey: selectedEventData[0].id) {
                                let decoder = JSONDecoder()
                                if let decodedData = try? decoder.decode(FavData.self, from: data) {
                                    eventIsFav = true
                                }
                            }
                            displaySelectedEventData = true
                        }
                        
                    } catch {
                        print("Error parsing JSON: \(error.localizedDescription)")
                    }
                }
                
            } catch let error {
                print("Error: \(error.localizedDescription)")
            }
        }
        //completion()
    }
    
    func fetchSpotifyData() {
        print("REACHED SPOTIFY")
        count = 0
        displaySelectedSpotifyData = false
        selectedSpotifyData.removeAll()
        musicArtists.removeAll()
        callSpotify = false
        
        let eventUrlSpotify = URL(string: "https://vkmodi571hw8.wl.r.appspot.com/api/selectedeventdata?eventid=" + eventId)!
    
        AF.request(eventUrlSpotify).response { response in
            guard let data = response.data else {
                print("Error: No data returned")
                return
            }
            do {
                if let selectedEventJsonSpotify = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    //print(type(of:selectedEventJsonSpotify))
                    
                    guard let selectedEventJsonDataSpotify = try? JSONSerialization.data(withJSONObject: selectedEventJsonSpotify, options: []) else {
                        print("Error creating JSON data")
                        return
                    }
                    
                    do {
                        if let parsedSelectedEventJsonDataSpotify = try JSONSerialization.jsonObject(with: selectedEventJsonDataSpotify, options: []) as? [String: Any] {
                        
                            do {
                                
                                var attractionsLen: [[String: Any]] = []
                                do {
                                    guard let embedded = parsedSelectedEventJsonDataSpotify["_embedded"] as? [String: Any],
                                          let attractionsLenTemp = embedded["attractions"] as? [[String: Any]] else {
                                        throw NSError(domain: "myDomain", code: 0, userInfo: nil)
                                    }
                                    attractionsLen = attractionsLenTemp
                                }
                                catch {
                                    print("error attractionsLen")
                                }
                                
                                showSpotify = false
                                for i in 0..<attractionsLen.count {
                                    
                                    var classificationsLen: [[String: Any]] = []
                                    do {
                                        guard let embedded = parsedSelectedEventJsonDataSpotify["_embedded"] as? [String: Any],
                                              let attractions = embedded["attractions"] as? [[String: Any]],
                                              let classificationsLenTemp = attractions[i]["classifications"] as? [[String: Any]] else {
                                            throw NSError(domain: "myDomain", code: 0, userInfo: nil)
                                        }
                                        classificationsLen = classificationsLenTemp
                                    }
                                    catch {
                                        print("error classificationsLen")
                                    }
                                    
                                    for j in 0..<classificationsLen.count {
                                        var artistCategory = ""
                                        do {
                                            guard let embedded = parsedSelectedEventJsonDataSpotify["_embedded"] as? [String: Any],
                                                  let attractions = embedded["attractions"] as? [[String: Any]],
                                                  let classifications = attractions[i]["classifications"] as? [[String: Any]],
                                                  let segment = classifications[j]["segment"] as? [String: Any],
                                                  let name1 = segment["name"] as? String else {
                                                        throw NSError(domain: "myDomain", code: 0, userInfo: nil)
                                                  }
                                                  artistCategory = name1
                                        }
                                        catch {
                                            print("error artistCategory")
                                        }
                                        if artistCategory == "Music" {
                                            showSpotify = true
                                        }
                                    }
                                
                                    if showSpotify == true {
                                        
                                        //var artistToSearch: String = ""
                                        do {
                                            guard let embedded = parsedSelectedEventJsonDataSpotify["_embedded"] as? [String: Any],
                                                  let attractions = embedded["attractions"] as? [[String: Any]],
                                                  let nameA = attractions[i]["name"] as? String else {
                                                        throw NSError(domain: "myDomain", code: 0, userInfo: nil)
                                                  }
                                            musicArtists.append(nameA)
                                            //artistToSearch = nameA
                                        }
                                        //print("Array", musicArtists)
                                        
                                        //print("fetching artist data")
                                        
                                        
                                        /*guard let embedded = parsedSelectedEventJsonDataSpotify["_embedded"] as? [String: Any],
                                              let attractions = embedded["attractions"] as? [[String: Any]],
                                              let artistName = attractions[i]["name"] as? String else {
                                                  return
                                              }*/
                                        
                                        //displaySelectedSpotifyData = false
                                        
                                        //print(artistToSearch)
                                        //var spotifyUrl = URL(string: "https://vkmodi571hw8.wl.r.appspot.com/api/spotifyAPI?artistname=" + artistToSearch)!
                                        //print(spotifyUrl)
                                        /**/
                                        
                                        
                                    } else {
                                        let selectedSpotifyDataTemp = selectedSpotifyStruct(isArtist: false, id: eventId, name: "", image: "", followers: "", popularity: "", link: "", albumImages: [""])
                                        selectedSpotifyData.removeAll()
                                        selectedSpotifyData.append(selectedSpotifyDataTemp)
                                        displaySelectedSpotifyData = true
                                    }
                                
                                }
                                callSpotify = true
                            } catch {
                                print("ERRROR")
                            }
                            //print("AND HERE", musicArtists)
                            var temporarySpotifyArtists = artistsStruct(name: musicArtists)
                            artistsToSearch.removeAll()
                            artistsToSearch.append(temporarySpotifyArtists)
                            //print("before", artistsToSearch)
                            callSpotifyAPI()
                            print("SPOTIFY1", selectedSpotifyData)
                        }
                        
                    } catch {
                        print("Error parsing JSON: \(error.localizedDescription)")
                    }
                    //print("AND HERE 1", musicArtists)
                }
                
            } catch let error {
                print("Error: \(error.localizedDescription)")
            }
            //print("AND HERE 2", musicArtists)
        }
        
        //print("after", artistsToSearch)
        //completion()
    }
    
    func callSpotifyAPI() {
        //print("Here Spotify Call")
        //var spotifyUrl = URL(string: "https://vkmodi571hw8.wl.r.appspot.com/api/spotifyAPI?artistname=" + artistsToSearch[0].name[0])!
        //print(spotifyUrl)
        
        //print("2", artistsToSearch)
        for s in 0..<artistsToSearch[0].name.count {
            //print(s)
            //print(artistsToSearch[0].name)
            //let spotifyUrl = URL(string: "https://vkmodi571hw8.wl.r.appspot.com/api/spotifyAPI?artistname=" + artistsToSearch[0].name[s])
            var artistNameSend = artistsToSearch[0].name[s].replacingOccurrences(of: " ", with: "%20")
            let spotifyUrl = "https://vkmodi571hw8.wl.r.appspot.com/api/spotifyAPI?artistname=" + artistNameSend

            //let spotifyUrl = artistsToSearch[0].name[s]
            //print(spotifyUrl)
            //print("Here")
            //print (artistsToSearch[0].name[s])
            
            AF.request(spotifyUrl).response { response in
                guard let data = response.data else {
                    print("Error: No data returned", spotifyUrl)
                    return
                }
                do {
                    if let selectedSpotifyJson = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        //print(type(of:selectedSpotifyJson))
                        
                        guard let selectedSpotifyJsonData = try? JSONSerialization.data(withJSONObject: selectedSpotifyJson, options: []) else {
                            print("Error creating JSON data")
                            return
                        }
                        
                        do {
                            if let parsedSelectedSpotifyJsonData = try JSONSerialization.jsonObject(with: selectedSpotifyJsonData, options: []) as? [String: Any] {
                                var nameArtist: String = ""
                                do {
                                    guard let searchResult = parsedSelectedSpotifyJsonData["searchResult"] as? [String: Any],
                                          let artists = searchResult["artists"] as? [String: Any],
                                          let items = artists["items"] as? [[String: Any]],
                                          let nameTemp = items[0]["name"] as? String else {
                                        //print("error")
                                        throw NSError(domain: "myDomain", code: 0, userInfo: nil)
                                    }
                                    nameArtist = nameTemp
                                } catch {
                                    print("ERROR 1")
                                }
                                
                                //print("3")
                                var followers: String = ""
                                do {
                                    guard let searchResult = parsedSelectedSpotifyJsonData["searchResult"] as? [String: Any],
                                          let artists = searchResult["artists"] as? [String: Any],
                                          let items = artists["items"] as? [[String: Any]],
                                          let follow = items[0]["followers"] as? [String: Any],
                                          let count = follow["total"] as? Int else {
                                        //print("error")
                                        throw NSError(domain: "myDomain", code: 0, userInfo: nil)
                                    }
                                    followers = String(count)
                                } catch {
                                    print("ERROR 2")
                                }
                                
                                //print("4")
                                var popularity: String = ""
                                do {
                                    guard let searchResult = parsedSelectedSpotifyJsonData["searchResult"] as? [String: Any],
                                          let artists = searchResult["artists"] as? [String: Any],
                                          let items = artists["items"] as? [[String: Any]],
                                          let pop = items[0]["popularity"] as? Int else {
                                        //print("error")
                                        throw NSError(domain: "myDomain", code: 0, userInfo: nil)
                                    }
                                    popularity = String(pop)
                                } catch {
                                    print("ERROR 3")
                                }
                                
                                //print("5")
                                var link: String = ""
                                do {
                                    guard let searchResult = parsedSelectedSpotifyJsonData["searchResult"] as? [String: Any],
                                          let artists = searchResult["artists"] as? [String: Any],
                                          let items = artists["items"] as? [[String: Any]],
                                          let urls = items[0]["external_urls"] as? [String: Any],
                                          let linkTemp = urls["spotify"] as? String else {
                                        //print("error")
                                        throw NSError(domain: "myDomain", code: 0, userInfo: nil)
                                    }
                                    link = linkTemp
                                } catch {
                                    print("ERROR 4")
                                }
                                
                                //print("6")
                                var image: String = ""
                                do {
                                    guard let searchResult = parsedSelectedSpotifyJsonData["searchResult"] as? [String: Any],
                                          let artists = searchResult["artists"] as? [String: Any],
                                          let items = artists["items"] as? [[String: Any]],
                                          let images = items[0]["images"] as? [[String: Any]],
                                          let imageTemp = images[0]["url"] as? String else {
                                        //print("error")
                                        throw NSError(domain: "myDomain", code: 0, userInfo: nil)
                                    }
                                    image = imageTemp
                                } catch {
                                    print("ERROR 5")
                                }
                                
                                //print("7")
                                var imageNum: Int = 0
                                do {
                                    guard let albumsResult = parsedSelectedSpotifyJsonData["albumsResult"] as? [String: Any],
                                          let items = albumsResult["items"] as? [[String: Any]] else {
                                        //print("error")
                                        throw NSError(domain: "myDomain", code: 0, userInfo: nil)
                                    }
                                    imageNum = min(items.count, 3)
                                } catch {
                                    print("ERROR 6")
                                }
                                
                                var imageArray: [String] = []
                                for k in 0..<imageNum {
                                    do {
                                        guard let albumsResult = parsedSelectedSpotifyJsonData["albumsResult"] as? [String: Any],
                                              let items = albumsResult["items"] as? [[String: Any]],
                                              let images = items[k]["images"] as? [[String: Any]],
                                              let imageTemp = images[0]["url"] as? String else {
                                            //print("error")
                                            throw NSError(domain: "myDomain", code: 0, userInfo: nil)
                                        }
                                        imageArray.append(imageTemp)
                                        //print (imageTemp)
                                    } catch {
                                        print("ERROR 7")
                                    }
                                }
                                
                                let selectedSpotifyDataTemp = selectedSpotifyStruct(isArtist: true, id: eventId, name: nameArtist, image: image, followers: followers, popularity: popularity, link: link, albumImages: imageArray)
                                
                                selectedSpotifyData.append(selectedSpotifyDataTemp)
                                //print("SPOTIFY4", selectedSpotifyData)
                                count = count + 1
                                if (count == artistsToSearch.count + 1) {
                                    displaySelectedSpotifyData = true
                                    print("SPOTIFY4", selectedSpotifyData)
                                    print("SPOTIFY4-1", selectedSpotifyData[0].name)
                                    //print(count)
                                }
                                //print(type(of: eventData))
                                //print(selectedEventData[0].id)
                            }
                            
                        } catch {
                            print("Error parsing JSON: \(error.localizedDescription)")
                        }
                    }
                    
                } catch let error {
                    print("Error: \(error.localizedDescription)")
                }
            }
            //displaySelectedSpotifyData = true
            //print("SPOTIFY", selectedSpotifyData)
            print("SPOTIFY2", selectedSpotifyData)
        }
        print("SPOTIFY3", selectedSpotifyData)
    }
    
    func fetchVenueData () {
        print("REACHED VENUE")
        let venue4Url = URL(string: "https://vkmodi571hw8.wl.r.appspot.com/api/selectedeventdata?eventid=" + eventId)!
        
        AF.request(venue4Url).response { response in
            guard let data = response.data else {
                print("Error: No data returned Venue1")
                return
            }
            do {
                if let selectedEventJson1 = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    //print(type(of:selectedEventJson1))
                    
                    guard let selectedEventJsonData1 = try? JSONSerialization.data(withJSONObject: selectedEventJson1, options: []) else {
                        print("Error creating JSON data")
                        return
                    }
                    
                    do {
                        if let parsedSelectedEventJsonData1 = try JSONSerialization.jsonObject(with: selectedEventJsonData1, options: []) as? [String: Any] {
                            
                            guard let embedded = parsedSelectedEventJsonData1["_embedded"] as? [String: Any],
                                  let venues = embedded["venues"] as? [[String: Any]],
                                  let selectedEventVenue = venues[0]["name"] as? String else {
                                      return
                                  }
                            callVenueAPI(selectedEventVenue: selectedEventVenue)
                        }
                        
                    } catch {
                        print("Error parsing JSON: \(error.localizedDescription)")
                    }
                }
                
            } catch let error {
                print("Error: \(error.localizedDescription)")
            }
        }
        //completion()
    }
    
    func callVenueAPI(selectedEventVenue: String) {
        var venue_forurl = selectedEventVenue.replacingOccurrences(of: " ", with: "%20")
        var venueURL = "https://vkmodi571hw8.wl.r.appspot.com/api/selectedvenuedata?venue=" + venue_forurl;
        //print(venueURL)
        print(venueURL)
        AF.request(venueURL).response { response in
            guard let data = response.data else {
                print("Error: No data returned venue2")
                return
            }
            do {
                if let selectedVenueJson = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    //print(type(of:selectedVenueJson))
                    
                    guard let selectedVenueJsonData = try? JSONSerialization.data(withJSONObject: selectedVenueJson, options: []) else {
                        print("Error creating JSON data")
                        return
                    }
                    
                    do {
                        if let parsedSelectedVenueJsonData = try JSONSerialization.jsonObject(with: selectedVenueJsonData, options: []) as? [String: Any] {
                            
                            selectedVenueData.removeAll()
                            
                            var venueName: String = " "
                            do {
                                guard let embedded = parsedSelectedVenueJsonData["_embedded"] as? [String: Any],
                                      let venues = embedded["venues"] as? [[String: Any]],
                                      let name = venues[0]["name"] as? String else {
                                    print("error")
                                    throw NSError(domain: "myDomain", code: 0, userInfo: nil)
                                }
                                venueName = name
                            } catch {
                                print("ERROR name")
                            }
                            
                            var venueAddress: String = " "
                            do {
                                guard let embedded = parsedSelectedVenueJsonData["_embedded"] as? [String: Any],
                                      let venues = embedded["venues"] as? [[String: Any]],
                                      let address = venues[0]["address"] as? [String: Any],
                                      let line1Temp = address["line1"] as? String else {
                                    print("error")
                                    throw NSError(domain: "myDomain", code: 0, userInfo: nil)
                                }
                                venueAddress = line1Temp + ", "
                            } catch {
                                print("ERROR line1Temp")
                            }
                            
                            do {
                                guard let embedded = parsedSelectedVenueJsonData["_embedded"] as? [String: Any],
                                      let venues = embedded["venues"] as? [[String: Any]],
                                      let city = venues[0]["city"] as? [String: Any],
                                      let cityNameTemp = city["name"] as? String else {
                                    print("error")
                                    throw NSError(domain: "myDomain", code: 0, userInfo: nil)
                                }
                                venueAddress = venueAddress + cityNameTemp + ", "
                            } catch {
                                print("ERROR cityNameTemp")
                            }
                            
                            do {
                                guard let embedded = parsedSelectedVenueJsonData["_embedded"] as? [String: Any],
                                      let venues = embedded["venues"] as? [[String: Any]],
                                      let state = venues[0]["state"] as? [String: Any],
                                      let stateNameTemp = state["name"] as? String else {
                                    print("error")
                                    throw NSError(domain: "myDomain", code: 0, userInfo: nil)
                                }
                                venueAddress = venueAddress + stateNameTemp
                            } catch {
                                print("ERROR stateNameTemp")
                            }
                            
                            var venuePhone: String = " "
                            do {
                                guard let embedded = parsedSelectedVenueJsonData["_embedded"] as? [String: Any],
                                      let venues = embedded["venues"] as? [[String: Any]],
                                      let boxOfficeInfo = venues[0]["boxOfficeInfo"] as? [String: Any],
                                      let phoneNumberDetail = boxOfficeInfo["phoneNumberDetail"] as? String else {
                                    print("error")
                                    throw NSError(domain: "myDomain", code: 0, userInfo: nil)
                                }
                                venuePhone = phoneNumberDetail
                            } catch {
                                print("ERROR phoneNumberDetail")
                            }
                            
                            var venueHours: String = " "
                            do {
                                guard let embedded = parsedSelectedVenueJsonData["_embedded"] as? [String: Any],
                                      let venues = embedded["venues"] as? [[String: Any]],
                                      let boxOfficeInfo = venues[0]["boxOfficeInfo"] as? [String: Any],
                                      let openHoursDetail = boxOfficeInfo["openHoursDetail"] as? String else {
                                    print("error")
                                    throw NSError(domain: "myDomain", code: 0, userInfo: nil)
                                }
                                venueHours = openHoursDetail
                            } catch {
                                print("ERROR openHoursDetail")
                            }
                            
                            var venueGenRule: String = " "
                            do {
                                guard let embedded = parsedSelectedVenueJsonData["_embedded"] as? [String: Any],
                                      let venues = embedded["venues"] as? [[String: Any]],
                                      let generalInfo = venues[0]["generalInfo"] as? [String: Any],
                                      let generalRule = generalInfo["generalRule"] as? String else {
                                    print("error")
                                    throw NSError(domain: "myDomain", code: 0, userInfo: nil)
                                }
                                venueGenRule = generalRule
                            } catch {
                                print("ERROR venueGenRule")
                            }
                            
                            var venueChiRule: String = " "
                            do {
                                guard let embedded = parsedSelectedVenueJsonData["_embedded"] as? [String: Any],
                                      let venues = embedded["venues"] as? [[String: Any]],
                                      let generalInfo = venues[0]["generalInfo"] as? [String: Any],
                                      let childRule = generalInfo["childRule"] as? String else {
                                    print("error")
                                    throw NSError(domain: "myDomain", code: 0, userInfo: nil)
                                }
                                venueChiRule = childRule
                                print(venueChiRule)
                            } catch {
                                print("ERROR venueChiRule")
                            }
                            
                            var venueID: String = " "
                            do {
                                guard let embedded = parsedSelectedVenueJsonData["_embedded"] as? [String: Any],
                                      let venues = embedded["venues"] as? [[String: Any]],
                                      let venID = venues[0]["id"] as? String else {
                                    print("error")
                                    throw NSError(domain: "myDomain", code: 0, userInfo: nil)
                                }
                                venueID = venID
                            } catch {
                                print("ERROR venID")
                            }
                            
                            let selectedVenueDataTemp = selectedVenueStruct(name: venueName, address: venueAddress, phone: venuePhone, open_hours: venueHours, gen_rule: venueGenRule, child_rule: venueChiRule, id: venueID)
                            
                            selectedVenueData.append(selectedVenueDataTemp)
                            print("VENUE", selectedVenueData)
                            //print(type(of: eventData))
                            //print(selectedEventData[0].id)
                            displaySelectedVenueData = true
                        }
                        
                    } catch {
                        print("Error parsing JSON: \(error.localizedDescription)")
                    }
                }
                
            } catch let error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}
 
struct ContentView: View {
    
    @State var displayEventData: Bool = false
    @State var searched: Bool = false
    @State var keyword: String = ""
    @State var distance: String = "10"
    @State var category: String = "Default"
    @State var location: String = ""
    @State var autoDetect: Bool = false
    @State var eventIdToPass: String = ""
    @State var hasEventResults: Bool = false
    @State var keywordSuggestions = [String]()
    @State var showKeywordSuggestions = false

    
    let categories = ["Default", "Music", "Sports", "Arts & Theatre", "Film", "Miscellaneous"]
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Event Search")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.black)) {
                            HStack {
                                Text("Keyword:")
                                TextField("", text: $keyword, onCommit: {
                                    fetchKeyword(with: keyword)
                                })
                                
                                    /*.onReceive(Just(keyword)) { newValue in
                                            fetchKeyword()
                                        }*/
                            }
                            
                            HStack {
                                Text("Distance:")
                                TextField("10", text: $distance)
                                    .keyboardType(.numberPad)
                            }
                            
                            Picker("Category", selection: $category) {
                                ForEach(categories, id: \.self) { category in
                                    Text(category)
                                        .foregroundColor(.blue)
                                }
                                .foregroundColor(.blue)
                            }
                            
                            if !autoDetect {
                                HStack {
                                    Text("Location:")
                                        TextField("", text: $location)
                                            .keyboardType(.numberPad)
                                    }
                            }
                            
                            Toggle("Auto-detect my location", isOn: $autoDetect)
                            
                            VStack(alignment: .center) {
                                HStack {
                                    if (keyword.count > 0 && (location.count > 0 || autoDetect)) {
                                        Button(action: {
                                            submitButtonCall()
                                            self.searched = true
                                        }) {
                                            Text("Submit")
                                                .foregroundColor(.white)
                                                .padding()
                                                .background(Color.red)
                                                .cornerRadius(10)
                                        }
                                    } else {
                                        Button(action: {
                                        }) {
                                            Text("Submit")
                                                .foregroundColor(.white)
                                                .padding()
                                                .background(Color.gray)
                                                .cornerRadius(10)
                                        }
                                        .disabled(true)
                                    }
                                    
                                    
                                    Button(action: {
                                        // Add your clear button action here
                                        self.keyword = ""
                                        self.distance = "10"
                                        self.category = "Default"
                                        self.location = ""
                                        self.autoDetect = false
                                        self.displayEventData = false
                                        self.searched = false
                                    }) {
                                        Text("Clear")
                                            .foregroundColor(.white)
                                            .padding()
                                            .background(Color.blue)
                                            .cornerRadius(10)
                                    }
                                }
                            }.frame(maxWidth: .infinity)
                            .padding()
                        }
                }
                /*
                .sheet(isPresented: $showKeywordSuggestions) {
                    VStack {
                        Text("Suggestions")
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .padding()
                        Text("showKeywordSuggestions: \(showKeywordSuggestions.description)")
                        Text("1")
                        List(keywordSuggestions, id: \.self) { suggestion in
                            Text(suggestion)
                            Text("2")
                        }
                        ForEach(keywordSuggestions, id: \.self) { suggestion in
                            Text(suggestion)
                            Text("2")
                        }

                    }
                }*/
                
                
                if showKeywordSuggestions {
                    VStack {
                        Text("Suggestions")
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .padding()
                        List(keywordSuggestions, id: \.self) { suggestion in
                            Text(suggestion)
                                .onTapGesture {
                                    self.keyword = suggestion
                                    showKeywordSuggestions = false
                                }
                        }
                    }
                    .background(Color.white)
                    .transition(.move(edge: .top))
                    .padding(.top, -370)
                }
                
                Spacer()
                
                //if searched {
                    if displayEventData {
                        if hasEventResults == true {
                            List {
                                Section(header: Text("Results")
                                    .font(.title)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color.black)) {
                                        ForEach(sortedEventData) { event in
                                            NavigationLink(destination: EventView(eventId: event.id)) {
                                                HStack {
                                                    Text(event.date + "|" + event.time)
                                                        .font(.footnote)
                                                        .foregroundColor(Color.gray)
                                                        .lineLimit(3)
                                                    KFImage(URL(string: event.imageUrl))
                                                        .resizable()
                                                        .frame(width: 40, height: 40)
                                                        .aspectRatio(contentMode: .fit)
                                                        .cornerRadius(4)
                                                    Text(event.name)
                                                        .fontWeight(.bold)
                                                        .lineLimit(3)
                                                    Text(event.venue)
                                                        .foregroundColor(Color.gray)
                                                        .lineLimit(3)
                                                }
                                            }
                                        }
                                    }
                            }
                            
                        }
                        
                        else {
                            List {
                                Section(header: Text("Results")
                                    .font(.title)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color.black)) {
                                        Text("No result available")
                                            .foregroundColor(Color.red)
                                    }
                            }
                            
                            //.padding(.top, -350)
                        }
                    } /*else {
                        VStack {
                            ProgressView()
                            Text("Please wait...")
                                .foregroundColor(Color.gray)
                        }
                        .padding(.top, -350)
                    }*/
                //}
            }
            .navigationBarItems(trailing:
                NavigationLink(destination: FavsView()) {
                    Image(systemName: "heart.circle.fill")
                }
            )
        }
        .navigationBarTitle("Event Search")
        .opacity(1.0)
    }
    
    func fetchKeyword (with keyword: String) {
        //keywordSuggestions = ["item1", "item2", "item3"]
        showKeywordSuggestions = false
        //print(keywordSuggestions)
        //print(showKeywordSuggestions)
        
        if keyword.count > 4 {
            print(keyword)
            //showKeywordSuggestions = false
            self.keywordSuggestions.removeAll()
            var keywordSend = keyword.replacingOccurrences(of: " ", with: "%20")
            let keywordURL = URL(string: "https://vkmodi571hw8.wl.r.appspot.com/api/autocomplete?autokeyword=" + keywordSend)!
            AF.request(keywordURL).response { response in
                guard let data = response.data else {
                    print("Error: No data returned")
                    return
                }
                do {
                    if let keywordJson = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        //print(type(of:eventJson))
                        
                        guard let keywordJsonData = try? JSONSerialization.data(withJSONObject: keywordJson, options: []) else {
                            print("Error creating JSON data")
                            return
                        }
                        
                        do {
                            if let parsedKeywordJsonData = try JSONSerialization.jsonObject(with: keywordJsonData, options: []) as? [String: Any] {
                                
                                //print(parsedKeywordJsonData)
                                
                                var keywordCount: [[String: Any]] = []
                                do {
                                    guard let embedded = parsedKeywordJsonData["_embedded"] as? [String: Any],
                                          let keywordCountTemp = embedded["attractions"] as? [[String: Any]] else {
                                        //print("error")
                                        throw NSError(domain: "myDomain", code: 0, userInfo: nil)
                                    }
                                    keywordCount = keywordCountTemp
                                } catch {
                                    print("error keywordCount")
                                }
                                
                                print(keywordURL)
                                print(keywordCount.count)
                                
                                for i in 0..<keywordCount.count {
                                    
                                    do {
                                        guard let embedded = parsedKeywordJsonData["_embedded"] as? [String: Any],
                                              let attractions = embedded["attractions"] as? [[String: Any]],
                                              let keywordSuggestionTemp = attractions[i]["name"] as? String else {
                                            //print("error")
                                            throw NSError(domain: "myDomain", code: 0, userInfo: nil)
                                        }
                                        self.keywordSuggestions.append(keywordSuggestionTemp)
                                    } catch {
                                        print("error keywordCount")
                                    }
                                
                                }
                                
                            }
                            
                            showKeywordSuggestions = true
                            print(keywordSuggestions)
                            print(showKeywordSuggestions)
                            
                        } catch {
                            print("Error parsing JSON: \(error.localizedDescription)")
                        }
                    }
                    
                } catch let error {
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func submitButtonCall() {
        displayEventData = false
        
        var keywordSend = ""
        var locationSend = ""
        
        keywordSend = keyword.replacingOccurrences(of: " ", with: "%20")
        locationSend = location.replacingOccurrences(of: " ", with: "%20")
        
        var url = URL(string: "https://vkmodi571hw8.wl.r.appspot.com/api/formdata?keyword=" + keywordSend + "&distance=" + distance + "&category=" + category + "&location=" + locationSend)!

        if autoDetect {
            print("autodetect ON")
            var autoDetectUrl = "https://ipinfo.io/json?token=c9dddc2021ebf6"
            
            AF.request(autoDetectUrl).response { response in
                guard let data = response.data else {
                    print("Error: No data returned")
                    return
                }
                do {
                    if let autoLocJson = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        //print(type(of:eventJson))
                        
                        guard let autoLocJsonData = try? JSONSerialization.data(withJSONObject: autoLocJson, options: []) else {
                            print("Error creating JSON data")
                            return
                        }
                        
                        do {
                            if let parsedAutoLocJsonData = try JSONSerialization.jsonObject(with: autoLocJsonData, options: []) as? [String: Any] {
                                
                                //print(parsedEventJsonData)
                                //print("1", type(of: eventJson))
                                //print("2", type(of: eventJsonData))
                                //print("3", type(of: parsedEventJsonData))
                                var autoLoc = ""
                                do {
                                    guard let city = parsedAutoLocJsonData["city"] as? String else {
                                                autoLoc = "LA"
                                              throw NSError(domain: "myDomain", code: 0, userInfo: nil)
                                          }
                                    
                                    autoLoc = city
                                } catch {
                                    print("error autoLoc")
                                }
                                
                                var autoLocSend = autoLoc.replacingOccurrences(of: " ", with: "%20")
                                url = URL(string: "https://vkmodi571hw8.wl.r.appspot.com/api/formdata?keyword=" + keywordSend + "&distance=" + distance + "&category=" + category + "&location=" + autoLocSend)!
                                print("AUTOLOC url", url)
                                fetchEvents(url: url)
                            }
                            
                        } catch {
                            print("Error parsing JSON: \(error.localizedDescription)")
                        }
                    }
                    
                } catch let error {
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
        else {
            fetchEvents(url: url)
        }
    }
    
    func fetchEvents(url: URL) {
        print("URL", url)
        AF.request(url).response { response in
            guard let data = response.data else {
                print("Error: No data returned")
                return
            }
            do {
                if let eventJson = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    //print(type(of:eventJson))
                    
                    guard let eventJsonData = try? JSONSerialization.data(withJSONObject: eventJson, options: []) else {
                        print("Error creating JSON data")
                        return
                    }
                    
                    do {
                        if let parsedEventJsonData = try JSONSerialization.jsonObject(with: eventJsonData, options: []) as? [String: Any] {
                            
                            //print(parsedEventJsonData)
                            //print("1", type(of: eventJson))
                            //print("2", type(of: eventJsonData))
                            //print("3", type(of: parsedEventJsonData))
                            
                            guard let page = parsedEventJsonData["page"] as? [String: Any],
                                  let totalElements = page["totalElements"] as? Int else {
                                return
                            }
                            if totalElements == 0 {
                                hasEventResults = false
                                displayEventData = true
                            } else {
                                hasEventResults = true
                            }
                            let eventLength = min(20, totalElements)
                                
                            //var eventData: [EventStruct] = []
                            eventData.removeAll()
                            print(eventLength)
                            for i in 0..<eventLength {
                                
                                guard let embedded = parsedEventJsonData["_embedded"] as? [String: Any],
                                      let events = embedded["events"] as? [[String: Any]],
                                      let dates = events[i]["dates"] as? [String: Any],
                                      let start = dates["start"] as? [String: Any],
                                      let eventDate = start["localDate"] as? String else {
                                          return
                                      }
                                //print("1")
                                
                                var eventTime = ""
                                do {
                                    guard let embedded = parsedEventJsonData["_embedded"] as? [String: Any],
                                          let events = embedded["events"] as? [[String: Any]],
                                          let dates = events[i]["dates"] as? [String: Any],
                                          let start = dates["start"] as? [String: Any],
                                          let eventTimeTemp = start["localTime"] as? String else {
                                              throw NSError(domain: "myDomain", code: 0, userInfo: nil)
                                          }
                                    
                                    eventTime = eventTimeTemp
                                } catch {
                                    print("error")
                                }
                                
                                //print("2")
                                guard let embedded = parsedEventJsonData["_embedded"] as? [String: Any],
                                      let events = embedded["events"] as? [[String: Any]],
                                      let images = events[i]["images"] as? [[String: Any]],
                                      let eventImageUrl = images[0]["url"] as? String else {
                                          return
                                      }
                                //print("3")
                                guard let embedded = parsedEventJsonData["_embedded"] as? [String: Any],
                                      let events = embedded["events"] as? [[String: Any]],
                                      let eventName = events[i]["name"] as? String else {
                                          return
                                      }
                                //print("4")
                                guard let embedded = parsedEventJsonData["_embedded"] as? [String: Any],
                                      let events = embedded["events"] as? [[String: Any]],
                                      let classifications = events[i]["classifications"] as? [[String: Any]],
                                      let segment = classifications[0]["segment"] as? [String: Any],
                                      let eventGenre = segment["name"] as? String else {
                                          return
                                      }
                                //print("5")
                                guard let embedded = parsedEventJsonData["_embedded"] as? [String: Any],
                                      let events = embedded["events"] as? [[String: Any]],
                                      let embedded1 = events[i]["_embedded"] as? [String: Any],
                                      let venues = embedded1["venues"] as? [[String: Any]],
                                      let eventVenue = venues[0]["name"] as? String else {
                                          return
                                      }
                                //print("6")
                                guard let embedded = parsedEventJsonData["_embedded"] as? [String: Any],
                                      let events = embedded["events"] as? [[String: Any]],
                                      let eventId = events[i]["id"] as? String else {
                                          return
                                      }
                                //print("7")
                                var eventDataTemp = EventStruct(id: eventId, name: eventName, imageUrl: eventImageUrl, date: eventDate, time: eventTime, venue: eventVenue, genre: eventGenre)
                                 
                                eventData.append(eventDataTemp)
                                //print("8")
                            }
                            
                            displayEventData = true
                            
                            sortEventData(eventData: eventData)
                            
                            //print(type(of: eventData))
                        }
                        
                    } catch {
                        print("Error parsing JSON: \(error.localizedDescription)")
                    }
                }
                
            } catch let error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func sortEventData(eventData: [EventStruct]) {
        //eventdata[i].date eventdata[i].time
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH-mm-ss"
        
        sortedEventData = eventData.sorted { (event1, event2) -> Bool in
            let date1 = formatter.date(from: "\(event1.date) \(event1.time)")
            let date2 = formatter.date(from: "\(event2.date) \(event2.time)")
            if let unwrappedDate1 = date1, let unwrappedDate2 = date2 {
                if unwrappedDate1 == unwrappedDate2 {
                    return event1.time < event2.time
                } else {
                    return unwrappedDate1 < unwrappedDate2
                }
            } else {
                return false
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
