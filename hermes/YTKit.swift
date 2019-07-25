//
//  YTKit.swift
//  hermes
//
//  Created by Aidan Cline on 3/11/19.
//  Copyright © 2019 Aidan Cline. All rights reserved.
//

import UIKit
import GoogleAPIClientForREST
import FirebaseCore

class YTCore {

    private let apiKey: String
    
    //testing keys
    //private let apiKey = "AIzaSyDElkUB12I-Ks-WTK52HA5fI6FZZ24jcDc"
    //private let apiKey = "AIzaSyD9tUI2N4f0745lYRXzmGVjTpFe2S61Ul0" // for when it stops working
    //private let apiKey = "AIzaSyCYnLCN3B2Kytv_E7hGdXhBepWud-rAaX0" // for when it stops working again
    //private let apiKey = "AIzaSyAR2b1ZZoXvChZt8p8zJsIjmLbaMgUFjK8" // for when it stops working 3x
    
    // api key for carson's app
    //private let apiKey = "AIzaSyBR6IjPUbn1ShQf_uYqd-4aYCamTiEAeY8"
    
    // breaks it in case there's terrible internet or something (to save quota)
    //private let apiKey = ""
    
    // api key for my app
    //private let apiKey = "AIzaSyC-0K6xZtvLbmkfU_AFsKNBrIJa9jev7Eg"
    
    // api key for maddy's app
    //private let apiKey = "AIzaSyCR7KGt9y1LjNXSuoDNLJQEQhqCYZz8QqY"
    
    // api key for nick's app
    //private let apiKey = "AIzaSyD28aO7EqD22pyl6OBg-TKVEg_qfRO7XR8"
    
    // api key for paige's app
    //private let apiKey = "AIzaSyA87p5-Uu_xx23bnT6Tcxt3wcSySY-3sW8"

    var url = URL(string: "https://www.googleapis.com/youtube/v3/")
    var identifier = ""
    
    convenience init() {
        self.init(identifier: "")
    }
    
    init(identifier: String) {
        self.identifier = identifier
        apiKey = FIRApp.defaultApp()?.options.apiKey ?? ""
    }
    
    func performGetRequest(targetURL: URL!, completion: @escaping (_ data: Data?, _ HTTPStatusCode: Int, _ error: Error?) -> Void) {
        let session = URLSession(configuration: .default)
        if settings.userAccessToken != nil {
            url = URL(string: targetURL.absoluteString)
        } else {
            url = URL(string: "\(targetURL.absoluteString)&key=\(apiKey)")!
        }
        var request = URLRequest(url: url!)
        if let userToken = settings.userAccessToken {
            request.addValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        }
        let task = session.dataTask(with: request) { (data: Data!, response: URLResponse!, error: Error!) in
            DispatchQueue.global(qos: .default).async {
                completion(data, (response as! HTTPURLResponse?)?.statusCode ?? -1, error)
            }
        }
        task.resume()
    }
    
    struct HTTPField {
        var value: String
        var header: String
    }

    func performPostRequest(targetURL: URL!, headers: [HTTPField]?, body: Data?, completion: @escaping (_ HTTPStatusCode: Int, _ error: Error?) -> Void) {
        let session = URLSession(configuration: .default)
        if settings.userAccessToken != nil {
            url = URL(string: targetURL.absoluteString)
        } else {
            url = URL(string: "\(targetURL.absoluteString)&key=\(apiKey)")!
        }
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.httpBody = body
        if let userToken = settings.userAccessToken {
            request.addValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        }
        if let headers = headers {
            for field in headers {
                request.addValue(field.value, forHTTPHeaderField: field.header)
            }
        }
        let task = session.dataTask(with: request) { (data: Data!, response: URLResponse!, error: Error!) in
            DispatchQueue.global(qos: .default).async {
                completion((response as! HTTPURLResponse?)?.statusCode ?? -1, error)
            }
        }
        task.resume()
    }
    
    func downloadImage(targetURL url: URL!, completion: @escaping (_ data: Data?, _ HTTPStatusCode: Int, _ error: Error?) -> Void) {
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { (data: Data!, response: URLResponse!, error: Error!) in
            DispatchQueue.global(qos: .default).async {
                completion(data, (response as! HTTPURLResponse?)?.statusCode ?? -1, error)
            }
        }
        task.resume()
    }
    
    func getInfo(_ completion: @escaping (() -> Void)) {
        
    }
    
}

class YTChannelAvatar: YTCore {
    
    private var data = GTLRYouTube_Channel()
    var GTLR: GTLRYouTube_Channel {
        return data
    }
    
    func setData(_ newData: GTLRYouTube_Channel) {
        data = newData
    }
    
    override func getInfo(_ completion: @escaping (() -> Void)) {
        super.getInfo(completion)
        url = URL(string: "https://www.googleapis.com/youtube/v3/channels?part=snippet&id=\(identifier)")
        performGetRequest(targetURL: url) { (data, status, error) in
            if let error = error {
                print(error)
            }
            if status != 200 {
                print("YTChannelAvatar returned HTTP status \(status)")
            }
            var json = Dictionary<AnyHashable, Any>()
            if let data = data {
                do {
                    json = try JSONSerialization.jsonObject(with: data, options: []) as! [AnyHashable: Any]
                } catch {
                    print("error serializing json request for YTChannelAvatar")
                }
            }
            let response = GTLRYouTube_ChannelListResponse(json: json)
            if let items = response.items {
                if items.count > 0 {
                    self.setData(items[0])
                }
            } else {
                print("YTChannelAvatar request returned nil")
            }
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func getAvatar(_ completion: @escaping (_ image: UIImage?) -> Void) {
        if let url = URL(string: data.snippet?.thumbnails?.defaultProperty?.url ?? "") {
            downloadImage(targetURL: url) { (data, status, error) in
                if let error = error {
                    print(error)
                }
                if status != 200 {
                    print("image download failed with code \(status)")
                }
                var image: UIImage?
                if let data = data {
                    image = UIImage(data: data)
                } else {
                    image = nil
                }
                DispatchQueue.main.async {
                    completion(image)
                }
            }
        }
    }
    
}

class YTChannel_DEPRECATED: YTCore {
    
    private var data = GTLRYouTube_Channel()
    var GTLR: GTLRYouTube_Channel {
        get {
            return data
        }
        set {
            data = newValue
        }
    }
    
    func setData(_ newData: GTLRYouTube_Channel) {
        data = newData
    }
    
    override func getInfo(_ completion: @escaping (() -> Void)) {
        super.getInfo(completion)
        url = URL(string: "https://www.googleapis.com/youtube/v3/channels?part=statistics,snippet,contentDetails&id=\(identifier)")
        performGetRequest(targetURL: url) { (data, status, error) in
            if let error = error {
                print(error)
            }
            if status != 200 {
                print("YTChannel error: HTTP status \(status)")
            }
            var json = Dictionary<AnyHashable, Any>()
            if let data = data {
                do {
                    json = try JSONSerialization.jsonObject(with: data, options: []) as! [AnyHashable: Any]
                } catch {
                    print("error serializing json request for YTChannel")
                }
                let response = GTLRYouTube_ChannelListResponse(json: json)
                if let items = response.items {
                    if items.count > 0 {
                        self.setData(items[0])
                    }
                }
            } else {
                print("YTChannel request returned nil")
            }
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func getAvatar(_ completion: @escaping (_ image: UIImage?) -> Void) {
        if let url = URL(string: data.snippet?.thumbnails?.defaultProperty?.url ?? "") {
            downloadImage(targetURL: url) { (data, status, error) in
                if let error = error {
                    print(error)
                }
                if status != 200 {
                    print("image download failed with code \(status)")
                }
                var image: UIImage?
                if let data = data {
                    image = UIImage(data: data)
                } else {
                    image = nil
                }
                DispatchQueue.main.async {
                    completion(image)
                }
            }
        }
    }
    
    var title: String? {
        return data.snippet?.title
    }
    
    var description: String? {
        return data.snippet?.descriptionProperty
    }
    
    var subscribers: NSNumber? {
        return data.statistics?.subscriberCount
    }
    
    var videoCount: NSNumber? {
        return data.statistics?.videoCount
    }
    
    var viewCount: NSNumber? {
        return data.statistics?.viewCount
    }
    
    var uploadsPlaylistID: String? {
        return data.contentDetails?.relatedPlaylists?.uploads
    }
    
    var featuredVideoID: String? {
        return data.brandingSettings?.channel?.unsubscribedTrailer
    }
    
    func subscribe() {
        print("will subscribe to \(title!)")
    }
    
    func unsubscribe() {
        print("will unsubscribe from \(title!)")
    }
    
}

class YTChannelFull: YTChannel_DEPRECATED {
    
    override func getInfo(_ completion: @escaping (() -> Void)) {
        super.getInfo(completion)
        url = URL(string: "https://www.googleapis.com/youtube/v3/channels?part=statistics,snippet,contentDetails,brandingSettings&id=\(identifier)")
        performGetRequest(targetURL: url) { (data, status, error) in
            if let error = error {
                print(error)
            }
            if status != 200 {
                print("YTChannel error: HTTP status \(status)")
            }
            var json = Dictionary<AnyHashable, Any>()
            if let data = data {
                do {
                    json = try JSONSerialization.jsonObject(with: data, options: []) as! [AnyHashable: Any]
                } catch {
                    print("error serializing json request for YTChannel")
                }
            }
            let response = GTLRYouTube_ChannelListResponse(json: json)
            if let items = response.items {
                if items.count > 0 {
                    self.setData(items[0])
                }
            } else {
                print("YTChannel request returned nil")
            }
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func getBanner(_ completion: @escaping (_ image: UIImage?) -> Void) {
        if let url = URL(string: GTLR.brandingSettings?.image?.bannerMobileMediumHdImageUrl ?? "") {
            downloadImage(targetURL: url) { (data, status, error) in
                if let error = error {
                    print(error)
                }
                if status != 200 {
                    print("image download failed with code \(status)")
                }
                var image: UIImage?
                if let data = data {
                    image = UIImage(data: data)
                } else {
                    image = nil
                }
                DispatchQueue.main.async {
                    completion(image)
                }
            }
        }
    }
    
}

class YTChannelSection: YTCore {
    
    var items = [String]()
    
    override func getInfo(_ completion: @escaping (() -> Void)) {
        super.getInfo(completion)
        url = URL(string: "https://www.googleapis.com/youtube/v3/channelSections?part=snippet,contentDetails&channelId=\(identifier)")
        performGetRequest(targetURL: url) { (data, status, error) in
            if let error = error {
                print(error)
            }
            if status != 200 {
                print("ytchannelsection returned status \(status)")
            }
            if let data = data {
                var json = Dictionary<AnyHashable, Any>()
                do {
                    json = try JSONSerialization.jsonObject(with: data, options: []) as! [AnyHashable: Any]
                } catch {
                    print("error serializing ytchannelsection json")
                }
                let response = GTLRYouTube_ChannelSectionListResponse(json: json)
                if let items = response.items {
                    for item in items {
                        if let id = item.contentDetails?.channels {
                            print(id)
                            self.items.append(id[0])
                        }
                    }
                }
            } else {
                print("ytchannelsection returned nil")
            }
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
}

class YTVideo_DEPRECATED: YTCore {
    
    var data = GTLRYouTube_Video()
    
    override func getInfo(_ completion: @escaping (() -> Void)) {
        super.getInfo(completion)
        url = URL(string: "https://www.googleapis.com/youtube/v3/videos?part=statistics,snippet&id=\(identifier)")
        performGetRequest(targetURL: url) { (data, status, error) in
            if let error = error {
                print(error)
            }
            if status != 200 {
                print("YTVideo error: HTTP status \(status)")
            }
            var json = Dictionary<AnyHashable, Any>()
            if let data = data {
                do {
                    json = try JSONSerialization.jsonObject(with: data, options: []) as! [AnyHashable: Any]
                } catch {
                    print("error serializing json request for YTChannel")
                }
            }
            let response = GTLRYouTube_VideoListResponse(json: json)
            if let items = response.items {
                if items.count > 0 {
                    self.data = items[0]
                }
            } else {
                let error = GTLRErrorObject(json: json)
                print(error.errors?[0].message ?? "unknown error loading YTChannel")
            }
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    var channelID: String? {
        return data.snippet?.channelId
    }
    
    var title: String? {
        return data.snippet?.localized?.title
    }
    
    var description: String? {
        return data.snippet?.descriptionProperty
    }
    
    var channelName: String? {
        return data.snippet?.channelTitle
    }
    
    var thumbnails: GTLRYouTube_ThumbnailDetails? {
        return data.snippet?.thumbnails
    }
    
    var views: NSNumber? {
        return data.statistics?.viewCount
    }
    
    var likes: NSNumber? {
        return data.statistics?.likeCount
    }
    
    var dislikes: NSNumber? {
        return data.statistics?.dislikeCount
    }
    
    var category: String? {
        return data.snippet?.categoryId
    }
    
    var uploadDate: Date? {
        return data.snippet?.publishedAt?.date
    }
    
    var length: String? {
        return data.contentDetails?.duration
    }
    
    func getThumbnail(_ completion: @escaping (_ image: UIImage?) -> Void) {
        var imageURL: URL?
        if let url = URL(string: data.snippet?.thumbnails?.standard?.url ?? "") {
            imageURL = url
        } else if let url = URL(string: data.snippet?.thumbnails?.medium?.url ?? "") {
            imageURL = url
        }
        if let url = imageURL {
            downloadImage(targetURL: url) { (data, status, error) in
                if let error = error {
                    print(error)
                }
                if status != 200 {
                    print("image download failed with code \(status)")
                }
                var image: UIImage?
                if let data = data {
                    image = UIImage(data: data)
                } else {
                    image = nil
                }
                DispatchQueue.main.async {
                    completion(image)
                }
            }
        } else if let url = URL(string: data.snippet?.thumbnails?.standard?.url ?? "") {
            downloadImage(targetURL: url) { (data, status, error) in
                if let error = error {
                    print(error)
                }
                if status != 200 {
                    print("image download failed with code \(status)")
                }
                var image: UIImage?
                if let data = data {
                    image = UIImage(data: data)
                } else {
                    image = nil
                }
                DispatchQueue.main.async {
                    completion(image)
                }
            }
        }
    }
    
}

class YTPlaylist_DEPRECATED: YTCore {
    
    private var data = GTLRYouTube_Playlist()
    
    override func getInfo(_ completion: @escaping (() -> Void)) {
        super.getInfo(completion)
        url = URL(string: "https://www.googleapis.com/youtube/v3/playlists?part=snippet,contentDetails&id=\(identifier)")
        performGetRequest(targetURL: url) { (data, status, error) in
            if let error = error {
                print(error)
            }
            if status != 200 {
                print("YTPlaylist error: HTTP status \(status)")
            }
            var json = Dictionary<AnyHashable, Any>()
            if let data = data {
                do {
                    json = try JSONSerialization.jsonObject(with: data, options: []) as! [AnyHashable: Any]
                } catch {
                    print("error serializing json request for YTPlaylist")
                }
            }
            let response = GTLRYouTube_PlaylistListResponse(json: json)
            self.data = response.items![0]
            if let items = response.items {
                if items.count > 0 {
                    self.data = items[0]
                }
            } else {
                print("YTPlaylist request returned nil")
            }
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
}

class YTPlaylistItems_DEPRECATED: YTCore {
    
    private var data = GTLRYouTube_PlaylistItemListResponse()
    
    var items: [GTLRYouTube_PlaylistItem] {
        if let items = data.items {
            return items
        } else {
            return [GTLRYouTube_PlaylistItem]()
        }
    }
    
    var GTLR: GTLRYouTube_PlaylistItemListResponse {
        return data
    }
    
    var maxResults = 25
    var pageToken: String?
    
    override func getInfo(_ completion: @escaping (() -> Void)) {
        super.getInfo(completion)
        var urlString = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=\(identifier)&maxResults=\(maxResults)"
        if pageToken != nil {
            urlString.append("&pageToken=\(pageToken!)")
        }
        url = URL(string: urlString)
        performGetRequest(targetURL: url) { (data, status, error) in
            if let error = error {
                print(error)
            }
            if status != 200 {
                print("YTPlaylistItems error: HTTP status \(status)")
            }
            var json = Dictionary<AnyHashable, Any>()
            if let data = data {
                do {
                    json = try JSONSerialization.jsonObject(with: data, options: []) as! [AnyHashable: Any]
                } catch {
                    print("error serializing YTPlaylistItems object")
                }
            }
            let response = GTLRYouTube_PlaylistItemListResponse(json: json)
            self.data = response
            if response.items == nil {
                print("YTPlaylistItems returned nil")
            }
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    var nextPageToken: String? {
        return data.nextPageToken
    }
    
    var previousPageToken: String? {
        return data.prevPageToken
    }
    
}

class YTPopularVideos: YTCore {
    
    var data = GTLRYouTube_VideoListResponse()
    var items = [YTVideo_DEPRECATED]()
    
    var maxResults = 10
    var pageToken: String?
    
    override func getInfo(_ completion: @escaping (() -> Void)) {
        super.getInfo(completion)
        url = URL(string: "https://www.googleapis.com/youtube/v3/videos?part=snippet,statistics&chart=mostPopular&locale=us&maxResults=\(maxResults)&regionCode=US\((pageToken != nil) ? "&pageToken=\(pageToken!)" : "")")
        performGetRequest(targetURL: url) { (data, status, error) in
            if let error = error {
                print(error)
            }
            if status != 200 {
                print("YTVideo error: HTTP status \(status)")
            }
            var json = Dictionary<AnyHashable, Any>()
            if let data = data {
                do {
                    json = try JSONSerialization.jsonObject(with: data, options: []) as! [AnyHashable: Any]
                } catch {
                    print("error serializing json request for YTPopularVideos")
                }
            }
            let response = GTLRYouTube_VideoListResponse(json: json)
            self.data = response
            if let items = response.items {
                for item in items {
                    let video = YTVideo_DEPRECATED()
                    video.data = item
                    self.items.append(video)
                }
            } else {
                let error = GTLRErrorObject(json: json)
                print(error.errors?[0].message ?? "unknown error loading YTChannel")
            }
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
}

extension String {
    func withUrlPercentEncoding() -> String? {
        //let unreserved = "-._~/?"
        let unreserved = "-._~?"
        let allowed = NSMutableCharacterSet.alphanumeric()
        allowed.addCharacters(in: unreserved)
        return addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)
    }
}

class YTSearch: YTCore {
    
    var data = GTLRYouTube_SearchListResponse()
    var resultIds = [String]()
    
    enum ResultTypes: String {
        case channel = "channel"
        case playlist = "playlist"
        case video = "video"
    }
    
    enum SearchSorts: String {
        case relevance = "relevance"
        case latest = "date"
        case top = "rating"
        case alphabetical = "title"
    }
    
    enum SafeSearchLevels: String {
        case none = "none"
        case moderate = "moderate"
        case strict = "strict"
    }
    
    var type = ResultTypes.video
    var sort = SearchSorts.relevance
    var safeSearchLevel = SafeSearchLevels.none
    var maxResults = 5
    var pageToken: String?
    var relatedToVideo: String? {
        didSet {
            type = .video
        }
    }
    
    var query: String?
    
    convenience init(type: ResultTypes) {
        self.init()
        self.type = type
    }
    
    override func getInfo(_ completion: @escaping (() -> Void)) {
        super.getInfo(completion)
        if query != nil || relatedToVideo != nil {
            var urlString = "https://www.googleapis.com/youtube/v3/search?part=snippet"
            urlString.append("&type=\(type)")
            urlString.append("&order=\(sort)")
            urlString.append("&safeSearch=\(safeSearchLevel)")
            urlString.append("&maxResults=\(maxResults)")
            urlString.append("&regionCode=US")
            urlString.append((pageToken != nil) ? "&pageToken=\(pageToken!)" : "")
            urlString.append((relatedToVideo != nil) ? "&relatedToVideoId=\(relatedToVideo!)" : "")
            urlString.append((query != nil) ? "&q=\(query!.withUrlPercentEncoding()!)" : "")
            url = URL(string: urlString)
            
            performGetRequest(targetURL: url) { (data, status, error) in
                if let error = error {
                    print(error)
                }
                if status != 200 {
                    print("ytsearch return http status \(status)")
                }
                var json = Dictionary<AnyHashable, Any>()
                if let data = data {
                    do {
                        json = try JSONSerialization.jsonObject(with: data, options: []) as! [AnyHashable: Any]
                    } catch {
                        print("ytsearch encountered an error serializing json data")
                    }
                }
                let response = GTLRYouTube_SearchListResponse(json: json)
                self.data = response
                if let items = response.items {
                    for item in items {
                        switch self.type {
                        case .channel:
                            self.resultIds.append(item.identifier?.channelId ?? "")
                        case .video:
                            self.resultIds.append(item.identifier?.videoId ?? "")
                        case .playlist:
                            self.resultIds.append(item.identifier?.playlistId ?? "")
                        }
                    }
                }
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
    
    var nextPageToken: String? {
        return data.nextPageToken
    }
    
    var previousPageToken: String? {
        return data.prevPageToken
    }
    
}

class YTChannel: YTCore {
    
    var data = GTLRYouTube_Channel()
    
    enum Parts: String {
        case snippet = "snippet"
        case contents = "contentDetails"
        case statistics = "statistics"
        case branding = "brandingSettings"
    }
    
    var parts: [Parts]?
    
    var username: String?
    
    var title: String? {
        return data.snippet?.title
    }
    
    var description: String? {
        return data.snippet?.descriptionProperty
    }
    
    var subscribers: NSNumber? {
        return data.statistics?.subscriberCount
    }
    
    var videoCount: NSNumber? {
        return data.statistics?.videoCount
    }
    
    var viewCount: NSNumber? {
        return data.statistics?.viewCount
    }
    
    var uploadsPlaylistID: String? {
        return data.contentDetails?.relatedPlaylists?.uploads
    }
    
    var featuredVideoID: String? {
        return data.brandingSettings?.channel?.unsubscribedTrailer
    }
    
    func subscribe(_ completion: (() -> Void)?) {
        let urlString = "https://www.googleapis.com/youtube/v3/subscriptions?part=snippet"
        let json: [String: Any] = ["snippet": [
                                        "resourceId":
                                                    ["kind": "youtube#channel",
                                                    "channelId": identifier]
            ]
        ]
        let data = try? JSONSerialization.data(withJSONObject: json)
        performPostRequest(targetURL: URL(string: urlString), headers: [.init(value: "application/json", header: "Accept"), .init(value: "application/json", header: "Content-Type")], body: data) { (status, error) in
            if let error = error {
                print(error)
            } else {
                completion?()
                NotificationCenter.default.post(name: .subscriptionsChanged, object: nil)
            }
        }
    }
    
    func unsubscribe(_ completion: (() -> Void)?) {
        let urlString = "https://www.googleapis.com/youtube/v3/subscriptions?id=\(identifier)"
        let session = URLSession(configuration: .default)
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = "DELETE"
        if let userToken = settings.userAccessToken {
            request.addValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        }
        let task = session.dataTask(with: request) { (data: Data!, response: URLResponse!, error: Error!) in
            DispatchQueue.global(qos: .default).async {
                let status = (response as! HTTPURLResponse?)?.statusCode ?? -1
                if status != 204 {
                    print("deleting subscription returned http status \(status)")
                }
                if let error = error {
                    print(error)
                } else {
                    completion?()
                    NotificationCenter.default.post(name: .subscriptionsChanged, object: nil)
                }
            }
        }
        task.resume()
    }
    
    func getAvatar(_ completion: @escaping (_ image: UIImage?) -> Void) {
        getAvatar(quality: .standard) { (image) in
            completion(image)
        }
    }
    
    enum AvatarQuality {
        case standard
        case medium
        case high
    }
    
    func getAvatar(quality: AvatarQuality, _ completion: @escaping (_ image: UIImage?) -> Void) {
        let standardURL = data.snippet?.thumbnails?.defaultProperty?.url
        let mediumURL = data.snippet?.thumbnails?.medium?.url
        let highURL = data.snippet?.thumbnails?.high?.url
        var urlString = ""
        switch quality {
        case .standard:
            urlString = data.snippet?.thumbnails?.defaultProperty?.url ?? ""
        case .medium:
            urlString = mediumURL ?? standardURL ?? ""
        case .high:
            urlString = highURL ?? mediumURL ?? standardURL ?? ""
        }
        if let url = URL(string: urlString) {
            downloadImage(targetURL: url) { (data, status, error) in
                if let error = error {
                    print(error)
                }
                if status != 200 {
                    print("avatar image download failed with code \(status)")
                }
                var image: UIImage?
                if let data = data {
                    image = UIImage(data: data)
                } else {
                    image = nil
                }
                DispatchQueue.main.async {
                    completion(image)
                }
            }
        }
    }
    
    func getBanner(_ completion: @escaping (_ image: UIImage?) -> Void) {
        if let url = URL(string: data.brandingSettings?.image?.bannerMobileMediumHdImageUrl ?? "") {
            downloadImage(targetURL: url) { (data, status, error) in
                if let error = error {
                    print(error)
                }
                if status != 200 {
                    print("banner image download failed with code \(status)")
                }
                var image: UIImage?
                if let data = data {
                    image = UIImage(data: data)
                } else {
                    image = nil
                }
                DispatchQueue.main.async {
                    completion(image)
                }
            }
        }
    }
    
    override func getInfo(_ completion: @escaping (() -> Void)) {
        super.getInfo(completion)
        if (username != nil || identifier != "") && parts != nil {
            var urlString = "https://www.googleapis.com/youtube/v3/channels?part="
            
            for (i, part) in parts!.enumerated() {
                urlString.append((i != 0) ? "," : "")
                urlString.append(part.rawValue)
            }
            
            urlString.append((username != nil) ? "&forUsername=\(username!)" : "&id=\(identifier)")
            url = URL(string: urlString)
            
            performGetRequest(targetURL: url) { (data, status, error) in
                if let error = error {
                    print(error)
                }
                if status != 200 {
                    print("error: ytchannel returned http status \(status)")
                    if status == 503 {
                        print("the quota for this api key has likely expired for today")
                    }
                }
                
                var json = [AnyHashable: Any]()
                if let data = data {
                    do {
                        json = try JSONSerialization.jsonObject(with: data, options: []) as! [AnyHashable: Any]
                    } catch {
                        print("error: ytchannel failed to serialize json")
                    }
                } else {
                    print("error: ytchannel get request failed")
                }
                
                let response = GTLRYouTube_ChannelListResponse(json: json)
                if let items = response.items {
                    if items.count > 0 {
                        self.data = items[0]
                    }
                }
                
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
    
}

class YTPlaylist: YTCore {
    
    var data = GTLRYouTube_Playlist()
    var contents: [YTVideo]?
    var parts: [Parts]?
    var maxResults = 5
    
    enum Parts: String {
        case snippet = "snippet"
        case contents = "contentDetails"
    }
    
    var pageToken: String?
    private(set) var nextPageToken: String?
    private(set) var previousPageToken: String?

    var title: String? {
        return data.snippet?.title
    }
    
    var uploadDate: Date? {
        return data.snippet?.publishedAt?.date
    }
    
    var parentChannelTitle: String? {
        return data.snippet?.channelTitle
    }

    var parentChannelID: String? {
        return data.snippet?.channelId
    }
    
    var length: Int? {
        return data.contentDetails?.itemCount?.intValue
    }
    
    override func getInfo(_ completion: @escaping (() -> Void)) {
        super.getInfo(completion)
        if identifier != "" && parts != nil {
            var urlString = "https://www.googleapis.com/youtube/v3/playlists?part="
            
            for (i, part) in parts!.enumerated() {
                urlString.append((i != 0) ? "," : "")
                urlString.append(part.rawValue)
            }
            
            urlString.append("&id=\(identifier)")
            url = URL(string: urlString)
            
            performGetRequest(targetURL: url) { (data, status, error) in
                if let error = error {
                    print(error)
                }
                if status != 200 {
                    print("error: ytplaylist returned http status \(status)")
                    if status == 503 {
                        print("the quota for this api key has likely expired for today")
                    }
                }
                
                var json = [AnyHashable: Any]()
                if let data = data {
                    do {
                        json = try JSONSerialization.jsonObject(with: data, options: []) as! [AnyHashable: Any]
                    } catch {
                        print("error: ytplaylist failed to serialize json")
                    }
                } else {
                    print("error: ytplaylist get request failed")
                }
                
                let response = GTLRYouTube_PlaylistListResponse(json: json)
                if let items = response.items {
                    if items.count > 0 {
                        self.data = items[0]
                    }
                }
                
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
    
    func getContents(_ completion: @escaping (() -> Void)) {
        if identifier != "" {
            var urlString = "https://www.googleapis.com/youtube/v3/playlistItems?part=contentDetails"
            urlString.append("&maxResults=\(maxResults)")
            urlString.append("&playlistId=\(identifier)")
            urlString.append((pageToken != nil) ? "&pageToken=\(pageToken!)" : "")
            
            url = URL(string: urlString)
            
            performGetRequest(targetURL: url) { (data, status, error) in
                if let error = error {
                    print(error)
                }
                
                if status != 200 {
                    print("error: ytplaylist contents returned http status \(status)")
                    if status == 503 {
                        print("the quota for this api key has likely expired for today")
                    }
                }
                
                var json = [AnyHashable: Any]()
                if let data = data {
                    do {
                        json = try JSONSerialization.jsonObject(with: data, options: []) as! [AnyHashable: Any]
                    } catch {
                        print("error: ytplaylist contents failed to serialize json")
                    }
                } else {
                    print("error: ytplaylist contents get request failed")
                }
                
                let response = GTLRYouTube_PlaylistItemListResponse(json: json)
                self.nextPageToken = response.nextPageToken
                self.previousPageToken = response.prevPageToken
                if let items = response.items {
                    self.contents = [YTVideo]()
                    for item in items {
                        let video = YTVideo(identifier: item.contentDetails?.videoId ?? "")
                        self.contents!.append(video)
                    }
                }
                
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
    
    func getThumbnail(_ completion: @escaping (_ image: UIImage?) -> Void) {
        var imageURL: URL?
        if let url = URL(string: data.snippet?.thumbnails?.standard?.url ?? "") {
            imageURL = url
        } else if let url = URL(string: data.snippet?.thumbnails?.medium?.url ?? "") {
            imageURL = url
        }
        if let url = imageURL {
            downloadImage(targetURL: url) { (data, status, error) in
                if let error = error {
                    print(error)
                }
                if status != 200 {
                    print("image download failed with code \(status)")
                }
                var image: UIImage?
                if let data = data {
                    image = UIImage(data: data)
                } else {
                    image = nil
                }
                DispatchQueue.main.async {
                    completion(image)
                }
            }
        } else if let url = URL(string: data.snippet?.thumbnails?.standard?.url ?? "") {
            downloadImage(targetURL: url) { (data, status, error) in
                if let error = error {
                    print(error)
                }
                if status != 200 {
                    print("image download failed with code \(status)")
                }
                var image: UIImage?
                if let data = data {
                    image = UIImage(data: data)
                } else {
                    image = nil
                }
                DispatchQueue.main.async {
                    completion(image)
                }
            }
        }
    }

}

class YTVideo: YTCore {
    
    var data = GTLRYouTube_Video()
    var listResponse = GTLRYouTube_VideoListResponse()
    var list = [YTVideo]()
    
    var identifierArray: [String]?
    var parts: [Parts]?
    var popularVideos = false
    var maxResults = 5
    
    enum Parts: String {
        case snippet = "snippet"
        case contents = "contentDetails"
        case statistics = "statistics"
    }
    
    var pageToken: String?
    private(set) var nextPageToken: String?
    private(set) var previousPageToken: String?
    
    var totalResults: Int? {
        return listResponse.pageInfo?.totalResults?.intValue
    }
    
    var channelID: String? {
        return data.snippet?.channelId
    }
    
    var title: String? {
        return data.snippet?.localized?.title
    }
    
    var description: String? {
        return data.snippet?.descriptionProperty
    }
    
    var channelName: String? {
        return data.snippet?.channelTitle
    }
    
    var thumbnails: GTLRYouTube_ThumbnailDetails? {
        return data.snippet?.thumbnails
    }
    
    var views: NSNumber? {
        return data.statistics?.viewCount
    }
    
    var likes: NSNumber? {
        return data.statistics?.likeCount
    }
    
    var dislikes: NSNumber? {
        return data.statistics?.dislikeCount
    }
    
    var category: String? {
        return data.snippet?.categoryId
    }
    
    var uploadDate: Date? {
        return data.snippet?.publishedAt?.date
    }
    
    var length: Int? {
        return listResponse.pageInfo?.totalResults?.intValue
    }
    
    enum VideoRatings: String {
        case liked = "like"
        case disliked = "dislike"
        case noRating = "none"
    }

    func setRating(_ rating: VideoRatings, _ completion: @escaping (() -> Void)) {
        let url = URL(string: "https://www.googleapis.com/youtube/v3/videos/rate?id=\(identifier)&rating=\(rating.rawValue)")!
        performPostRequest(targetURL: url, headers: nil, body: nil, completion: { (status, error) in
            if let error = error {
                print("error rating video \"\(self.title ?? "")\": \(error)")
            }
            
            if status != 204 {
                print("video rating returned status \(status)")
            }
            
            completion()
        })
    }
    
    func getRating(_ completion: @escaping ((_ rating: VideoRatings?) -> Void)) {
        let url = URL(string: "https://www.googleapis.com/youtube/v3/videos/getRating?id=\(identifier)")
        performGetRequest(targetURL: url) { (data, status, error) in
            if let error = error {
                print("error getting rating for video \(self.title ?? ""): \(error)")
            }
            
            if status != 200 {
                print("getting video rating returned status \(status)")
            }
            
            if let data = data {
                var json = [AnyHashable: Any]()
                do {
                    try json = JSONSerialization.jsonObject(with: data, options: []) as! [AnyHashable: Any]
                } catch {
                    print("error serializing json data for video rating")
                }
                let response = GTLRYouTube_VideoGetRatingResponse(json: json)
                switch response.items?.first?.rating {
                case "like":
                    completion(.liked)
                case "dislike":
                    completion(.disliked)
                case "none":
                    completion(.noRating)
                default:
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }
    }
    
    var duration: TimeInterval? {
        if let formattedDuration = data.contentDetails?.duration {
            let index = formattedDuration.index(formattedDuration.startIndex, offsetBy: 2)
            let endIndex = formattedDuration.index(formattedDuration.endIndex, offsetBy: -1)
            let substring = formattedDuration[index...endIndex]
            
            var string = String(substring)
            if !(string.contains("S")) {
                string = "0S\(string)"
            }
            if !(string.contains("M")) {
                string = "0M\(string)"
            }
            if !(string.contains("H")) {
                string = "0H\(string)"
            }
            string = string.replacingOccurrences(of: "H", with: ":")
            string = string.replacingOccurrences(of: "M", with: ":")
            string = string.replacingOccurrences(of: "S", with: "")
            
            return parseDuration(string)
        } else {
            return nil
        }
    }
    
    struct Duration {
        var seconds: Int
        var minutes: Int
        var hours: Int
        var days: Int
    }
    
    private func parseDuration(_ timeString:String) -> TimeInterval {
        guard !timeString.isEmpty else {
            return 0
        }
        
        var interval: Double = 0
        
        let parts = timeString.components(separatedBy: ":")
        for (index, part) in parts.reversed().enumerated() {
            interval += (Double(part) ?? 0) * pow(Double(60), Double(index))
        }
        
        return interval
    }
    
    override func getInfo(_ completion: @escaping (() -> Void)) {
        super.getInfo(completion)
        if (identifier != "" || popularVideos || identifierArray != nil) && parts != nil {
            var urlString = "https://www.googleapis.com/youtube/v3/videos?parts="
            if let parts = parts {
                for (i, part) in parts.enumerated() {
                    urlString.append((i == 0) ? "&part=" : ",")
                    urlString.append(part.rawValue)
                }
            }
            
            if identifier != "" {
                urlString.append("&id=\(identifier)")
            } else if let identifierArray = identifierArray {
                for (i, identifier) in identifierArray.enumerated() {
                    urlString.append((i == 0) ? "&id=" : ",")
                    urlString.append(identifier)
                }
            } else if popularVideos {
                urlString.append("&chart=mostPopular")
                urlString.append("&maxResults=\(maxResults)")
                if let pageToken = pageToken {
                    urlString.append("&pageToken=\(pageToken)")
                }
            }
            url = URL(string: urlString)
            performGetRequest(targetURL: url) { (data, status, error) in
                if let error = error {
                    print(error)
                }
                
                if status != 200 {
                    print("error: ytvideo returned http status \(status)")
                    if status == 503 {
                        print("the quota for this api key has likely expired for today")
                    }
                }
                
                var json = [AnyHashable: Any]()
                if let data = data {
                    do {
                        try json = JSONSerialization.jsonObject(with: data, options: []) as! [AnyHashable: Any]
                    } catch {
                        print("error: ytvideo failed to serialize json")
                    }
                } else {
                    print("error: ytvideo get request failed")
                }
                
                let response = GTLRYouTube_VideoListResponse(json: json)
                self.nextPageToken = response.nextPageToken
                self.previousPageToken = response.prevPageToken
                self.listResponse = response
                if let items = response.items {
                    if self.popularVideos || (self.identifierArray?.count != 0 && self.identifierArray != nil) {
                        for item in items {
                            let video = YTVideo(identifier: item.identifier ?? "")
                            video.data = item
                            video.parts = self.parts
                            self.list.append(video)
                        }
                    } else {
                        self.data = items[0]
                        self.identifier = self.data.identifier ?? ""
                    }
                } else {
                    print("error: ytvideo get request returned nothing")
                }
                
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
    
    func getThumbnail(_ completion: @escaping (_ image: UIImage?) -> Void) {
        var imageURL: URL?
        if let url = URL(string: data.snippet?.thumbnails?.standard?.url ?? "") {
            imageURL = url
        } else if let url = URL(string: data.snippet?.thumbnails?.medium?.url ?? "") {
            imageURL = url
        }
        if let url = imageURL {
            downloadImage(targetURL: url) { (data, status, error) in
                if let error = error {
                    print(error)
                }
                if status != 200 {
                    print("image download failed with code \(status)")
                }
                var image: UIImage?
                if let data = data {
                    image = UIImage(data: data)
                } else {
                    image = nil
                }
                DispatchQueue.main.async {
                    completion(image)
                }
            }
        } else if let url = URL(string: data.snippet?.thumbnails?.standard?.url ?? "") {
            downloadImage(targetURL: url) { (data, status, error) in
                if let error = error {
                    print(error)
                }
                if status != 200 {
                    print("image download failed with code \(status)")
                }
                var image: UIImage?
                if let data = data {
                    image = UIImage(data: data)
                } else {
                    image = nil
                }
                DispatchQueue.main.async {
                    completion(image)
                }
            }
        }
    }

}

class YTSubscriptions: YTCore {
    
    var list = [YTChannel]()
    
    enum Sorts: String {
        case alphabetical = "alphabetical"
        case relevance = "relevance"
        case newest = "unread"
    }
    
    var sort = Sorts.alphabetical

    func subscribe(identifier: String) {
        YTChannel(identifier: identifier).subscribe(nil)
    }
    
    func unsubscribe(identifier: String) {
        YTChannel(identifier: identifier).unsubscribe(nil)
    }

    var maxResults = 5

    func getSubscriptions(_ completion: @escaping () -> Void) {
        let url = URL(string: "https://www.googleapis.com/youtube/v3/subscriptions&id=\(identifier)?part=snippet&sort=\(sort.rawValue)&maxResults=\(maxResults)")
        performGetRequest(targetURL: url) { (data, status, error) in
            if let error = error {
                print(error)
            }
            
            if status != 200 {
                print(status)
            }
            
            if let data = data {
                var json = [AnyHashable: Any]()
                do {
                    try json = JSONSerialization.jsonObject(with: data, options: []) as! [AnyHashable: Any]
                } catch {
                    print("error serializing json for subscriptions")
                }
                let response = GTLRYouTube_SubscriptionListResponse(json: json)
                if let items = response.items {
                    for item in items {
                        if let id = item.snippet?.channelId {
                            self.list.append(YTChannel(identifier: id))
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                completion()
            }
        }
    }

    func getUserSubscriptions(_ completion: @escaping () -> Void) {
        let url = URL(string: "https://www.googleapis.com/youtube/v3/subscriptions?part=snippet&mine=true&sort=\(sort.rawValue)&maxResults=50")
        performGetRequest(targetURL: url) { (data, status, error) in
            if let error = error {
                print("user subscriptions returned error \(error)")
            }
            
            if status != 200 {
                print("user subscriptions returned http status \(status)")
            }
            
            if let data = data {
                var json = [AnyHashable: Any]()
                do {
                    try json = JSONSerialization.jsonObject(with: data, options: []) as! [AnyHashable: Any]
                } catch {
                    print("error serializing json for subscriptions")
                }
                let response = GTLRYouTube_SubscriptionListResponse(json: json)
                if let items = response.items {
                    for item in items {
                        if let id = item.snippet?.resourceId?.channelId {
                            self.list.append(YTChannel(identifier: id))
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                completion()
            }
        }
    }
}
