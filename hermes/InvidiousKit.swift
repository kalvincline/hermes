//
//  YTKit-Inv.swift
//  hermes
//
//  Created by Aidan Cline on 5/28/19.
//  Copyright © 2019 Aidan Cline. All rights reserved.
//

import UIKit

extension String {
    var withPercentEncoding: String? {
        let unreserved = "-._~?"
        let allowed = NSMutableCharacterSet.alphanumeric()
        allowed.addCharacters(in: unreserved)
        return addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)
    }
}

class URLDataHandler {
    
    struct HTTPField {
        var value: String
        var header: String
    }
    
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case delete = "DELETE"
        case put = "PUT"
        case none
    }
    
    static func performHTTPRequest(url: URL!, method: HTTPMethod, body: Data?, fields: [HTTPField]?, _ completion: ((_ data: Data?, _ status: Int, _ error: Error?) -> Void)?) {
        var request = URLRequest(url: url, cachePolicy: .reloadRevalidatingCacheData, timeoutInterval: 120)
        request.httpMethod = (method == .none) ? nil : method.rawValue
        if let body = body {
            request.httpBody = body
        }
        for field in fields ?? [] {
            request.addValue(field.value, forHTTPHeaderField: field.header)
        }
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                completion?(data, (response as? HTTPURLResponse)?.statusCode ?? -1, error)
            }
        }
        
        task.resume()
    }
    
    static func downloadImage(url: URL, _ completion: ((_ image: UIImage?) -> Void)?) {
        var newUrl = URL(string: url.absoluteString)
        if !url.absoluteString.contains("https") {
            newUrl = URL(string: "https:\(url.absoluteString)")
        }
        performHTTPRequest(url: newUrl, method: .none, body: nil, fields: nil) { (data, status, error) in
            var image: UIImage?
            if let error = error {
                print("error downloading image: \(error.localizedDescription)")
                print(newUrl ?? "no image url")
            } else {
                if let data = data {
                    image = UIImage(data: data)
                }
            }
            
            DispatchQueue.main.async {
                completion?(image)
            }
        }
    }
    
}

class InvidiousCore {
    
    static let apiURL = "https://invidio.us/api/v1/"
    
    struct Thumbnail {
        var low: String
        var medium: String
        var high: String
        var maxRes: String
    }
    
    var description: String {
        return "InvidiousCore"
    }
    
}

class InvidiousVideo: InvidiousCore {
    
    var identifier: String?
    var json: [AnyHashable: Any]?
    
    override var description: String {
        return "InvidiousVideo with identifier \(String(describing: identifier)): {\n  title: \(String(describing: title)),\n  thumbnails: \(String(describing: thumbnails)),\n  description: \(String(describing: descriptionText)),\n  published: \(String(describing: published)),\n  lenght: \(String(describing: length)),\n  views: \(String(describing: views)),\n  likes: \(String(describing: likes)),\n  dislikes: \(String(describing: dislikes)),\n  ageRestricted: \(String(describing: ageRestricted)),\n  channelTitle: \(String(describing: channelTitle)),\n  channelID: \(String(describing: channelID)),\n  channelThumbnails: \(String(describing: channelThumbnails)),\n  channelSubCount: \(String(describing: channelSubCount)),\n  streamURLs: \(String(describing: streamURLs)),\n  relatedVideos: \(String(describing: recommendedVideos))\n}"
    }
    
    init(identifier: String?) {
        super.init()
        self.identifier = identifier
    }
    
    enum Field: String {
        case title = "title"
        case thumbnails = "videoThumbnails"
        case description = "description"
        case published = "published"
        case length = "lengthSeconds"
        case views = "viewCount"
        case likes = "likeCount"
        case dislikes = "dislikeCount"
        case ageRestricted = "isFamilyFriendly"
        case channelTitle = "author"
        case channelID = "authorId"
        case channelThumbnails = "authorThumbnails"
        case channelSubCount = "subCountText"
        case streamURLs = "adaptiveFormats"
        case videoURLs = "formatStreams"
        case relatedVideos = "recommendedVideos"
        case all = "title,videoThumbnails,description,published,lengthSeconds,viewCount,likeCount,dislikeCount,isFamilyFriendly,author,authorId,authorThumbnails,subCountText,adaptiveFormats,recommendedVideos"
    }
    
    var fields: [Field] = [.all]
    
    struct VideoURLs {
        var audioOnly: String?
        var quality144p: String?
        var quality240p: String?
        var quality360p: String?
        var quality480p: String?
        var quality720p: String?
        var quality1080p: String?
        var quality720p60: String?
        var quality1080p60: String?
    }
    
    var title: String?
    var thumbnails: Thumbnail?
    var descriptionText: String?
    var published: Date?
    var length: Int?
    var views: Int?
    var likes: Int?
    var dislikes: Int?
    var ageRestricted: Bool?
    var channelID: String?
    var channelTitle: String?
    var channelThumbnails: Thumbnail?
    var channelSubCount: Int?
    var streamURLs: VideoURLs?
    var videoURLs: VideoURLs?
    var aspectRatio: Double?
    var recommendedVideos: [InvidiousVideo]?
    
    func getData(fields: [Field], _ completion: (() -> Void)?) {
        self.fields = fields
        getData(completion)
    }
    
    func getData(_ completion: (() -> Void)?) {
        if let id = identifier {
            var urlString = "\(InvidiousCore.apiURL)videos/\(id)?fields="
            for field in fields {
                urlString.append(field.rawValue)
                urlString.append((field != fields.last) ? "," : "")
            }
            
            let url = URL(string: urlString)!
            URLDataHandler.performHTTPRequest(url: url, method: .get, body: nil, fields: nil) { (data, status, error) in
                if let error = error {
                    print("inv-video error: \(error.localizedDescription)")
                } else {
                    if let data = data {
                        var json = [AnyHashable : Any]()
                        do {
                            json = try JSONSerialization.jsonObject(with: data) as! [AnyHashable : Any]
                            self.json = json
                        } catch {
                            print("inv-video error: json serialization failed")
                            print(url)
                        }
                        
                        self.title = json["title"] as? String
                        self.descriptionText = json["description"] as? String
                        self.views = json["viewCount"] as? Int
                        self.likes = json["likeCount"] as? Int
                        self.dislikes = json["dislikeCount"] as? Int
                        self.ageRestricted = !(json["isFamilyFriendly"] as? Bool ?? true)
                        self.length = json["lengthSeconds"] as? Int
                        self.channelTitle = json["author"] as? String
                        self.channelID = json["authorId"] as? String
                        
                        if let urlArray = json["adaptiveFormats"] as? [[String: Any]] {
                            self.streamURLs = VideoURLs(audioOnly: nil, quality144p: nil, quality240p: nil, quality360p: nil, quality480p: nil, quality720p: nil, quality1080p: nil, quality720p60: nil, quality1080p60: nil)
                            for url in urlArray {
                                if url["container"] as? String == "mp4" {
                                    if url["qualityLabel"] as? String == "1080p60" {
                                        self.streamURLs!.quality1080p60 = url["url"] as? String
                                    } else if url["qualityLabel"] as? String == "1080p" {
                                        self.streamURLs!.quality1080p = url["url"] as? String
                                    } else if url["qualityLabel"] as? String == "720p60" {
                                        self.streamURLs!.quality720p60 = url["url"] as? String
                                    } else if url["qualityLabel"] as? String == "720p" {
                                        self.streamURLs!.quality720p = url["url"] as? String
                                    } else if url["qualityLabel"] as? String == "480p" {
                                        self.streamURLs!.quality480p = url["url"] as? String
                                    } else if url["qualityLabel"] as? String == "360p" {
                                        self.streamURLs!.quality360p = url["url"] as? String
                                    } else if url["qualityLabel"] as? String == "240p" {
                                        self.streamURLs!.quality240p = url["url"] as? String
                                    } else if url["qualityLabel"] as? String == "144p" {
                                        self.streamURLs!.quality144p = url["url"] as? String
                                    }
                                } else if url["container"] as? String == "m4a" {
                                    self.streamURLs!.audioOnly = url["url"] as? String
                                }
                            }
                        }
                        
                        if let urlArray = json["formatStreams"] as? [[String: Any]] {
                            self.videoURLs = VideoURLs(audioOnly: nil, quality144p: nil, quality240p: nil, quality360p: nil, quality480p: nil, quality720p: nil, quality1080p: nil, quality720p60: nil, quality1080p60: nil)
                            for url in urlArray {
                                if url["container"] as? String == "mp4" {
                                    print(url["qualityLabel"] as! String)
                                    if url["qualityLabel"] as? String == "1080p60" {
                                        self.videoURLs!.quality1080p60 = url["url"] as? String
                                    } else if url["qualityLabel"] as? String == "1080p" {
                                        self.videoURLs!.quality1080p = url["url"] as? String
                                    } else if url["qualityLabel"] as? String == "720p60" {
                                        self.videoURLs!.quality720p60 = url["url"] as? String
                                    } else if url["qualityLabel"] as? String == "720p" {
                                        self.videoURLs!.quality720p = url["url"] as? String
                                    } else if url["qualityLabel"] as? String == "480p" {
                                        self.videoURLs!.quality480p = url["url"] as? String
                                    } else if url["qualityLabel"] as? String == "360p" {
                                        self.videoURLs!.quality360p = url["url"] as? String
                                    } else if url["qualityLabel"] as? String == "240p" {
                                        self.videoURLs!.quality240p = url["url"] as? String
                                    } else if url["qualityLabel"] as? String == "144p" {
                                        self.videoURLs!.quality144p = url["url"] as? String
                                    }
                                } else if url["container"] as? String == "m4a" {
                                    self.videoURLs!.audioOnly = url["url"] as? String
                                }
                            }
                        }
                        
                        if let thumbnailArray = json["videoThumbnails"] as? [[String: Any]] {
                            self.thumbnails = Thumbnail(low: "", medium: "", high: "", maxRes: "")
                            for thumbnail in thumbnailArray {
                                if thumbnail["quality"] as? String == "maxresdefault" {
                                    self.thumbnails?.maxRes = thumbnail["url"] as! String
                                } else if thumbnail["quality"] as? String == "sddefault" {
                                    self.thumbnails?.high = thumbnail["url"] as! String
                                } else if thumbnail["quality"] as? String == "high" {
                                    self.thumbnails?.medium = thumbnail["url"] as! String
                                } else if thumbnail["quality"] as? String == "medium" {
                                    self.thumbnails?.low = thumbnail["url"] as! String
                                }
                            }
                        }
                        
                        if let thumbnailArray = json["authorThumbnails"] as? [[String: Any]] {
                            self.channelThumbnails = Thumbnail(low: "", medium: "", high: "", maxRes: "")
                            for thumbnail in thumbnailArray {
                                let size = thumbnail["width"] as? Int
                                let url = thumbnail["url"] as! String
                                if size == 512 {
                                    self.channelThumbnails?.maxRes = url
                                } else if size == 176 {
                                    self.channelThumbnails?.high = url
                                } else if size == 100 {
                                    self.channelThumbnails?.medium = url
                                } else if size == 76 {
                                    self.channelThumbnails?.low = url
                                }
                            }
                        }
                        
                        if let videoArray = json["recommendedVideos"] as? [[String: Any]] {
                            self.recommendedVideos = []
                            for item in videoArray {
                                let video = InvidiousVideo(identifier: item["videoId"] as? String)
                                video.title = item["title"] as? String
                                video.channelTitle = item["author"] as? String
                                video.length = item["lengthSeconds"] as? Int
                                
                                if let thumbnailArray = item["authorThumbnails"] as? [[String: Any]] {
                                    video.channelThumbnails = Thumbnail(low: "", medium: "", high: "", maxRes: "")
                                    for thumbnail in thumbnailArray {
                                        let size = thumbnail["width"] as? Int
                                        let url = thumbnail["url"] as! String
                                        if size == 512 {
                                            self.channelThumbnails?.maxRes = url
                                        } else if size == 176 {
                                            self.channelThumbnails?.high = url
                                        } else if size == 100 {
                                            self.channelThumbnails?.medium = url
                                        } else if size == 76 {
                                            self.channelThumbnails?.low = url
                                        }
                                    }
                                }
                                
                                self.recommendedVideos?.append(video)
                            }
                        }
                        
                        if let interval = json["published"] as? Int64 {
                            self.published = Date(timeIntervalSince1970: Double(interval))
                        } else {
                            self.published = nil
                        }
                        
                        completion?()
                    } else {
                        completion?()
                    }
                }
            }
        } else {
            completion?()
        }
    }
    
}

class InvidiousChannel: InvidiousCore {
    
    var identifier: String?
    var json: [AnyHashable: Any]?
    
    override var description: String {
        return "InvidiousChannel with identifier \(String(describing: identifier)): {\n  title: \(String(describing: title)),\n  thumbnails: \(String(describing: thumbnails)),\n  description: \(String(describing: descriptionText)),\n  url: \(String(describing: url)),\n  banners: \(String(describing: banners)),\n  views: \(String(describing: views)),\n  subscribers: \(String(describing: subscribers)),\n  joined: \(String(describing: joined)),\n  ageRestricted: \(String(describing: ageRestricted)),\n  videos: \(String(describing: videos)),\n  channels: \(String(describing: channels))\n}"
    }
    
    init(identifier: String?) {
        super.init()
        self.identifier = identifier
    }
    
    enum VideoSorts: String {
        case new = "latest"
        case old = "oldest"
        case popular = "popular"
    }
    
    enum Field: String {
        case title = "author"
        case url = "authorUrl"
        case thumbnails = "authorThumbnails"
        case banners = "authorBanners"
        case subscribers = "subCount"
        case views = "totalViews"
        case joined = "joined"
        case ageRestricted = "isFamilyFriendly"
        case description = "description"
        case videos = "latestVideos"
        case channels = "relatedChannels"
        case all = "author,authorUrl,authorThumbnails,authorBanners,subCount,totalViews,joined,isFamilyFriendly,description,latestVideos,relatedChannels"
    }
    
    var fields: [Field]?
    
    var title: String?
    var url: String?
    var thumbnails: Thumbnail?
    var banners: Thumbnail?
    var subscribers: Int?
    var views: Int?
    var joined: Date?
    var ageRestricted: Bool?
    var descriptionText: String?
    var channels: [InvidiousChannel]?
    
    var videos: [InvidiousVideo]?
    var videosPage = 1
    var videosSort: VideoSorts?
    
    func getData(fields: [Field], _ completion: (() -> Void)?) {
        self.fields = fields
        getData(completion)
    }
    
    func getData(_ completion: (() -> Void)?) {
        if let id = identifier, let fields = fields {
            // TODO: add related channels
            var urlString = "\(InvidiousCore.apiURL)channels/\(id)?fields="
            for field in fields {
                urlString.append(field.rawValue)
                urlString.append((field != fields.last) ? "," : "")
            }
            
            let url = URL(string: urlString)!
            URLDataHandler.performHTTPRequest(url: url, method: .get, body: nil, fields: nil) { (data, status, error) in
                if let error = error {
                    print("inv-channel error: \(error.localizedDescription)")
                } else {
                    if let data = data {
                        var json = [AnyHashable: Any]()
                        do {
                            json = try JSONSerialization.jsonObject(with: data) as! [AnyHashable: Any]
                            self.json = json
                        } catch {
                            print("inv-channel error: json serialization failed")
                            print(url)
                        }
                        
                        self.title = json["author"] as? String
                        self.descriptionText = json["description"] as? String
                        self.ageRestricted = !(json["isFamilyFriendly"] as? Bool ?? true)
                        self.views = json["totalViews"] as? Int
                        self.subscribers = json["subCount"] as? Int
                        self.url = json["authorUrl"] as? String
                        
                        if let thumbnailArray = json["authorThumbnails"] as? [[String: Any]] {
                            self.thumbnails = Thumbnail(low: "", medium: "", high: "", maxRes: "")
                            for thumbnail in thumbnailArray {
                                let url = thumbnail["url"] as! String
                                let size = thumbnail["width"] as? Int
                                if size == 512 {
                                    self.thumbnails?.maxRes = url
                                } else if size == 176 {
                                    self.thumbnails?.high = url
                                } else if size == 100 {
                                    self.thumbnails?.medium = url
                                } else if size == 76 {
                                    self.thumbnails?.low = url
                                }
                            }
                        }
                        
                        if let thumbnailArray = json["authorBanners"] as? [[String: Any]] {
                            self.banners = Thumbnail(low: "", medium: "", high: "", maxRes: "")
                            for thumbnail in thumbnailArray {
                                let url = thumbnail["url"] as! String
                                let size = thumbnail["width"] as? Int
                                if size == 2560 {
                                    self.banners?.maxRes = url
                                } else if size == 2120 {
                                    self.banners?.high = url
                                } else if size == 1060 {
                                    self.banners?.medium = url
                                } else if size == 512 {
                                    self.banners?.low = url
                                }
                            }
                        }
                        
                        completion?()
                    } else {
                        completion?()
                    }
                }
            }
        }
    }
    
    func getVideos(page: Int, _ completion: (() -> Void)?) {
        videosPage = page
        getVideos(completion)
    }
    
    func getVideos(_ completion: (() -> Void)?) {
        if let id = identifier {
            var urlString = "\(InvidiousCore.apiURL)channels/videos/\(id)?page=\(videosPage)"
            urlString.append(videosSort != nil ? "&\(videosSort!.rawValue)" : "")
            let url = URL(string: urlString)!
            URLDataHandler.performHTTPRequest(url: url, method: .get, body: nil, fields: nil) { (data, status, error) in
                if let error = error {
                    print("inv-channel-videos error: \(error.localizedDescription)")
                } else {
                    if let data = data {
                        var json = [[AnyHashable: Any]]()
                        do {
                            json = try JSONSerialization.jsonObject(with: data) as? [[AnyHashable: Any]] ?? []
                        } catch {
                            print("inv-channel-videos error: json serialization failed")
                            print(url)
                        }
                        
                        if json.count > 0 {
                            self.videos = []
                            for json in json {
                                let video = InvidiousVideo(identifier: json["videoId"] as? String)
                                video.title = json["title"] as? String
                                video.channelTitle = json["author"] as? String
                                video.channelID = json["authorId"] as? String
                                video.descriptionText = json["description"] as? String
                                
                                if let thumbnailArray = json["videoThumbnails"] as? [[String: Any]] {
                                    video.thumbnails = Thumbnail(low: "", medium: "", high: "", maxRes: "")
                                    for thumbnail in thumbnailArray {
                                        if thumbnail["quality"] as? String == "maxresdefault" {
                                            video.thumbnails?.maxRes = thumbnail["url"] as! String
                                        } else if thumbnail["quality"] as? String == "sddefault" {
                                            video.thumbnails?.high = thumbnail["url"] as! String
                                        } else if thumbnail["quality"] as? String == "high" {
                                            video.thumbnails?.medium = thumbnail["url"] as! String
                                        } else if thumbnail["quality"] as? String == "medium" {
                                            video.thumbnails?.low = thumbnail["url"] as! String
                                        }
                                    }
                                }
                                
                                self.videos?.append(video)
                            }
                            
                            completion?()
                        } else {
                            completion?()
                        }
                    } else {
                        completion?()
                    }
                }
            }
        }
    }
    
}

class InvidiousPlaylist: InvidiousCore {
    
    var identifier: String?
    var page: Int?
    var json: [AnyHashable: Any]?
    
    init(identifier: String?) {
        super.init()
        self.identifier = identifier
    }
    
    enum Field: String {
        case title = "title"
        case channelTitle = "author"
        case channelID = "authorId"
        case channelThumbnails = "authorThumbnails"
        case description = "description"
        case count = "videoCount"
        case views = "viewCount"
        case lastUpdate = "updated"
        case items = "videos"
        case all = "title,author,authorId,authorThumbnails,description,videoCount,viewCount,updated,videos"
    }
    
    var fields: [Field]?
    
    var title: String?
    var channelTitle: String?
    var channelID: String?
    var channelThumbnails: Thumbnail?
    var descriptionText: String?
    var count: Int?
    var views: Int?
    var lastUpdate: Date?
    var items: [InvidiousVideo]?
    
    func getData(fields: [Field], _ completion: (() -> Void)?) {
        self.fields = fields
        getData(completion)
    }
    
    func getData(_ completion: (() -> Void)?) {
        if let id = identifier, let fields = fields {
            var urlString = "\(InvidiousCore.apiURL)playlists/\(id)?fields="
            for field in fields {
                urlString.append(field.rawValue)
                urlString.append((field != fields.last) ? "," : "")
            }
            
            let url = URL(string: urlString)!
            URLDataHandler.performHTTPRequest(url: url, method: .get, body: nil, fields: nil) { (data, status, error) in
                if let error = error {
                    print("inv-playlist error: \(error.localizedDescription)")
                } else {
                    if let data = data {
                        var json = [AnyHashable: Any]()
                        do {
                            json = try JSONSerialization.jsonObject(with: data) as! [AnyHashable: Any]
                            self.json = json
                        } catch {
                            print("inv-playlist error: json serialization failed")
                            print(url)
                        }
                        
                        self.title = json["title"] as? String
                        self.descriptionText = json["description"] as? String
                        self.views = json["totalViews"] as? Int
                        self.channelTitle = json["author"] as? String
                        self.channelID = json["authorId"] as? String
                        self.count = json["videoCount"] as? Int
                        
                        if let timeInterval = json["updated"] as? Int {
                            self.lastUpdate = Date(timeIntervalSince1970: Double(timeInterval))
                        }
                        
                        if let thumbnailArray = json["authorThumbnails"] as? [[String: Any]] {
                            self.channelThumbnails = Thumbnail(low: "", medium: "", high: "", maxRes: "")
                            for thumbnail in thumbnailArray {
                                let url = thumbnail["url"] as! String
                                let size = thumbnail["width"] as? Int
                                if size == 512 {
                                    self.channelThumbnails?.maxRes = url
                                } else if size == 176 {
                                    self.channelThumbnails?.high = url
                                } else if size == 100 {
                                    self.channelThumbnails?.medium = url
                                } else if size == 76 {
                                    self.channelThumbnails?.low = url
                                }
                            }
                        }
                        
                        if let videoArray = json["videos"] as? [[String: Any]] {
                            self.items = self.items ?? [InvidiousVideo]()
                            for item in videoArray {
                                let video = InvidiousVideo(identifier: item["videoId"] as? String)
                                video.title = item["title"] as? String
                                video.channelTitle = item["author"] as? String
                                video.channelID = item["authorId"] as? String
                                video.length = item["lengthSeconds"] as? Int
                                
                                if let thumbnailArray = item["authorThumbnails"] as? [[String: Any]] {
                                    video.channelThumbnails = Thumbnail(low: "", medium: "", high: "", maxRes: "")
                                    for thumbnail in thumbnailArray {
                                        let url = thumbnail["url"] as! String
                                        let size = thumbnail["width"] as? Int
                                        if size == 512 {
                                            video.channelThumbnails?.maxRes = url
                                        } else if size == 176 {
                                            video.channelThumbnails?.high = url
                                        } else if size == 100 {
                                            video.channelThumbnails?.medium = url
                                        } else if size == 76 {
                                            video.channelThumbnails?.low = url
                                        }
                                    }
                                }
                                
                                if let index = item["index"] as? Int {
                                    self.items![index] = video
                                }
                            }
                        }
                        
                        completion?()
                    }
                }
            }
        }
    }
    
}

class InvidiousSearch: InvidiousCore {
    
    var query: String?
    var page = 1
    var results: [InvidiousCore]?
    var json: [[String: Any]]?
    
    init(query: String?) {
        super.init()
        self.query = query
    }
    
    enum ResultType: String {
        case videos = "video"
        case playlists = "playlist"
        case channels = "channel"
        case all = "all"
    }
    
    enum Filters: String {
        case hd = "hd"
        case captioned = "subtitles"
        case cc0 = "creative_commons"
        case live = "live"
    }
    
    enum Duration: String {
        case short = "short"
        case long = "long"
    }
    
    enum Sorts: String {
        case relevance = "relevance"
        case popularity = "rating"
        case latest = "upload_date"
        case views = "view_count"
    }
    
    enum Interval: String {
        case hour = "hour"
        case day = "today"
        case week = "week"
        case month = "month"
        case year = "year"
    }
    
    var resultType = ResultType.videos
    var filters: [Filters]?
    var date: Interval?
    var duration: Duration?
    var sort = Sorts.relevance
    
    func getData(query: String?, _ completion: (() -> Void)?) {
        self.query = query
        getData(completion)
    }
    
    func getData(_ completion: (() -> Void)?) {
        if let query = query?.withPercentEncoding {
            var urlString = "\(InvidiousCore.apiURL)search?q=\(query)&sort_by=\(sort.rawValue)&type=\(resultType.rawValue)&page=\(page)"
            urlString.append((date != nil) ? "&date=\(date!.rawValue)" : "")
            urlString.append((duration != nil) ? "&duration=\(duration!.rawValue)" : "")
            if let filters = filters {
                urlString.append((filters.count > 0) ? "&features=" : "")
                for filter in filters {
                    urlString.append(filter.rawValue)
                    urlString.append((filter != filters.last) ? "," : "")
                }
            }
            
            let url = URL(string: urlString)!
            URLDataHandler.performHTTPRequest(url: url, method: .none, body: nil, fields: nil) { (data, status, error) in
                if let error = error {
                    print("inv-search error: \(error.localizedDescription)")
                } else {
                    if let data = data {
                        var json = [[String: Any]]()
                        do {
                            json = try JSONSerialization.jsonObject(with: data) as! [[String: Any]]
                            self.json = json
                        } catch {
                            print("inv-search error: json serialization failed")
                            print(url)
                        }
                        
                        self.results = [InvidiousCore]()
                        for result in json {
                            let type = result["type"] as? String
                            if type == "video" {
                                let video = InvidiousVideo(identifier: result["videoId"] as? String)
                                video.title = result["title"] as? String
                                video.descriptionText = result["description"] as? String
                                video.channelTitle = result["author"] as? String
                                video.channelID = result["authorId"] as? String
                                video.views = result["viewCount"] as? Int
                                video.length = result["lengthSeconds"] as? Int
                                if let publishedSeconds = result["published"] as? Int {
                                    video.published = Date(timeIntervalSince1970: Double(publishedSeconds))
                                }
                                
                                if let thumbnailArray = result["videoThumbnails"] as? [[String: Any]] {
                                    video.thumbnails = Thumbnail(low: "", medium: "", high: "", maxRes: "")
                                    for thumbnail in thumbnailArray {
                                        if thumbnail["quality"] as? String == "maxresdefault" {
                                            video.thumbnails?.maxRes = thumbnail["url"] as! String
                                        } else if thumbnail["quality"] as? String == "sddefault" {
                                            video.thumbnails?.high = thumbnail["url"] as! String
                                        } else if thumbnail["quality"] as? String == "high" {
                                            video.thumbnails?.medium = thumbnail["url"] as! String
                                        } else if thumbnail["quality"] as? String == "medium" {
                                            video.thumbnails?.low = thumbnail["url"] as! String
                                        }
                                    }
                                }
                                
                                self.results?.append(video)
                            } else if type == "channel" {
                                let channel = InvidiousChannel(identifier: result["authorId"] as? String)
                                channel.title = result["author"] as? String
                                channel.subscribers = result["subCount"] as? Int
                                channel.descriptionText = result["description"] as? String
                                
                                if let thumbnailArray = result["authorThumbnails"] as? [[String: Any]] {
                                    channel.thumbnails = Thumbnail(low: "", medium: "", high: "", maxRes: "")
                                    for thumbnail in thumbnailArray {
                                        let url = thumbnail["url"] as! String
                                        let size = thumbnail["width"] as? Int
                                        if size == 512 {
                                            channel.thumbnails?.maxRes = url
                                        } else if size == 176 {
                                            channel.thumbnails?.high = url
                                        } else if size == 100 {
                                            channel.thumbnails?.medium = url
                                        } else if size == 76 {
                                            channel.thumbnails?.low = url
                                        }
                                    }
                                }
                                
                                self.results?.append(channel)
                            } else if type == "playlist" {
                                let playlist = InvidiousPlaylist(identifier: result["playlistId"] as? String)
                                playlist.title = result["title"] as? String
                                playlist.channelTitle = result["author"] as? String
                                playlist.channelID = result["authorId"] as? String
                                playlist.count = result["videoCount"] as? Int
                                
                                if let items = result["videos"] as? [[String: Any]] {
                                    playlist.items = playlist.items ?? [InvidiousVideo]()
                                    for item in items {
                                        let video = InvidiousVideo(identifier: item["videoId"] as? String)
                                        video.title = item["title"] as? String
                                        video.length = item["lengthSeconds"] as? Int
                                        
                                        if let thumbnailArray = item["videoThumbnails"] as? [[String: Any]] {
                                            video.thumbnails = Thumbnail(low: "", medium: "", high: "", maxRes: "")
                                            for thumbnail in thumbnailArray {
                                                if thumbnail["quality"] as? String == "maxresdefault" {
                                                    video.thumbnails?.maxRes = thumbnail["url"] as! String
                                                } else if thumbnail["quality"] as? String == "sddefault" {
                                                    video.thumbnails?.high = thumbnail["url"] as! String
                                                } else if thumbnail["quality"] as? String == "high" {
                                                    video.thumbnails?.medium = thumbnail["url"] as! String
                                                } else if thumbnail["quality"] as? String == "medium" {
                                                    video.thumbnails?.low = thumbnail["url"] as! String
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                self.results?.append(playlist)
                            }
                        }
                        
                        completion?()
                    }
                }
            }
        }
    }
    
}

class InvidiousTrending: InvidiousCore {
    
    var json: [[String: Any]]?
    var videos: [InvidiousVideo]?
    
    enum Categories: String {
        case all = ""
        case music = "?type=music"
        case gaming = "?type=gaming"
        case news = "?type=news"
        case sports = "?type=sports"
    }
    
    var category = Categories.all
    
    func getData(_ completion: (() -> Void)?) {
        let url = URL(string: "\(InvidiousCore.apiURL)trending")!
        URLDataHandler.performHTTPRequest(url: url, method: .get, body: nil, fields: nil) { (data, status, error) in
            if let error = error {
                print("inv-trending error: \(error.localizedDescription)")
                completion?()
            } else {
                if status != 200 {
                    print("inv-trending error: http status \(status)")
                }
                
                if let data = data {
                    var json = [[String: Any]]()
                    do {
                        json = try JSONSerialization.jsonObject(with: data) as! [[String: Any]]
                        self.json = json
                    } catch {
                        print("inv-trending error: json serialization failed")
                        print(url)
                    }
                    
                    if json.count > 0 {
                        self.videos = []
                        for item in json {
                            let video = InvidiousVideo(identifier: item["videoId"] as? String)
                            video.title = item["title"] as? String
                            video.length = item["lengthSeconds"] as? Int
                            video.views = item["viewCount"] as? Int
                            video.channelTitle = item["author"] as? String
                            video.channelID = item["authorId"] as? String
                            video.descriptionText = item["description"] as? String
                            
                            if let dateSeconds = item["published"] as? Int {
                                video.published = Date(timeIntervalSince1970: Double(dateSeconds))
                            }
                            
                            if let thumbnailArray = item["videoThumbnails"] as? [[String: Any]] {
                                video.thumbnails = Thumbnail(low: "", medium: "", high: "", maxRes: "")
                                for thumbnail in thumbnailArray {
                                    if thumbnail["quality"] as? String == "maxresdefault" {
                                        video.thumbnails?.maxRes = thumbnail["url"] as! String
                                    } else if thumbnail["quality"] as? String == "sddefault" {
                                        video.thumbnails?.high = thumbnail["url"] as! String
                                    } else if thumbnail["quality"] as? String == "high" {
                                        video.thumbnails?.medium = thumbnail["url"] as! String
                                    } else if thumbnail["quality"] as? String == "medium" {
                                        video.thumbnails?.low = thumbnail["url"] as! String
                                    }
                                }
                            }
                            
                            self.videos?.append(video)
                        }
                    } else {
                        print("inv-trending error: no items found")
                    }
                    
                    completion?()
                } else {
                    completion?()
                }
            }
        }
    }
    
}

class InvidiousComment: InvidiousCore {
    
    var videoID: String?
    var json: [AnyHashable: Any]? {
        didSet {
            if let json = json {
                nextContinuation = json["continuation"] as? String
            }
        }
    }
    var items: [InvidiousComment]?
    
    init(videoID: String?) {
        super.init()
        self.videoID = videoID
    }
    
    var channelTitle: String?
    var channelThumbnails: Thumbnail?
    var channelID: String?
    var isEdited: Bool?
    var body: String?
    var published: Date?
    var likes: Int?
    var isChannelOwner: Bool?
    var isLovedByCreator: Bool?
    var replyCount: Int?
    var replyContinuation: String?
    var nextContinuation: String?
    
    enum Sort: String {
        case top = "top"
        case new = "new"
    }
    
    var continuation: String?
    var sort = Sort.top
    
    func getContinuation(_ completion: (() -> Void)?) {
        continuation = nextContinuation
        getData(completion)
    }
    
    func getData(_ completion: (() -> Void)?) {
        if let id = videoID {
            var urlString = "\(InvidiousCore.apiURL)comments/\(id)?sort_by=\(sort.rawValue)"
            urlString.append((continuation != nil) ? "&continuation=\(continuation!)" : "")
            
            let url = URL(string: urlString)!
            URLDataHandler.performHTTPRequest(url: url, method: .get, body: nil, fields: nil) { (data, status, error) in
                if let error = error {
                    print("inv-comment error: \(error.localizedDescription)")
                } else {
                    if let data = data {
                        self.items = [InvidiousComment]()
                        var json = [AnyHashable: Any]()
                        do {
                            json = try JSONSerialization.jsonObject(with: data) as! [AnyHashable: Any]
                            self.json = json
                        } catch {
                            print("inv-comment error: json serialization failed")
                            print(url)
                        }
                        
                        if let items = json["comments"] as? [[String: Any]] {
                            self.nextContinuation = json["continuation"] as? String
                            for item in items {
                                let comment = InvidiousComment(videoID: self.videoID)
                                comment.channelTitle = item["author"] as? String
                                comment.channelID = item["authorId"] as? String
                                comment.isEdited = item["isEdited"] as? Bool
                                comment.body = item["content"] as? String
                                comment.likes = item["likeCount"] as? Int
                                comment.isChannelOwner = item["authorIsChannelOwner"] as? Bool
                                
                                if (item["creatorHeart"] as? [String: Any]) != nil {
                                    comment.isLovedByCreator = true
                                } else {
                                    comment.isLovedByCreator = false
                                }
                                
                                if let replies = item["replies"] as? [String: Any] {
                                    comment.replyCount = replies["replyCount"] as? Int
                                    comment.replyContinuation = replies["continuation"] as? String
                                }
                                
                                if let timeInterval = item["published"] as? Int {
                                    self.published = Date(timeIntervalSince1970: Double(timeInterval))
                                }
                                
                                if let thumbnailArray = item["authorThumbnails"] as? [[String: Any]] {
                                    comment.channelThumbnails = Thumbnail(low: "", medium: "", high: "", maxRes: "")
                                    for thumbnail in thumbnailArray {
                                        let size = thumbnail["width"] as? Int
                                        let url = thumbnail["url"] as! String
                                        if size == 512 {
                                            comment.channelThumbnails?.maxRes = url
                                        } else if size == 176 {
                                            comment.channelThumbnails?.high = url
                                        } else if size == 100 {
                                            comment.channelThumbnails?.medium = url
                                        } else if size == 76 {
                                            comment.channelThumbnails?.low = url
                                        }
                                    }
                                }
                                
                                self.items?.append(comment)
                            }
                            
                            completion?()
                        }
                    }
                }
            }
        }
    }
    
}
