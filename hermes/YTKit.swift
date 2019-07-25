//
//  YTKit.swift
//  hermesforyoutube
//
//  Created by Aidan Cline on 7/25/19.
//  Copyright © 2019 Aidan Cline. All rights reserved.
//

import UIKit

class YouTube {
    private static let invidiousURL = "https://www.invidio.us/api/v1"
    private static let youtubeApiUrl = "https://www.googleapis.com/youtube/v3"
    
    struct Thumbnail {
        var low: String
        var medium: String
        var high: String
        var maxRes: String
    }
    
    struct Channel {
        var identifier: String?
        var title: String?
        var url: String?
        var thumbnails: Thumbnail?
        var banners: Thumbnail?
        var subscribers: Int?
        var totalViews: Int?
        var joined: Date?
        var isAgeRestricted: Bool?
        var description: String?
        var relatedChannels: [Channel]?
        
        enum Fields: String {
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
    }
    
    static func getChannel(identifier: String?, fields: [Channel.Fields], _ completion: @escaping (Channel) -> Void) {
        if let identifier = identifier {
            var urlString = "\(invidiousURL)/channels/\(identifier)?fields="
            for field in fields {
                urlString.append(field.rawValue)
                urlString.append((field != fields.last) ? "," : "")
            }
            
            URLDataHandler.performHTTPRequest(url: URL(string: urlString)!, method: .get, body: nil, fields: nil) { (data, status, error) in
                if let error = error {
                    print("YTKit.Channel error: \(error.localizedDescription)")
                } else {
                    if status != 200 {
                        print("YTKit.Channel request returned \(status)")
                    }
                    
                    if let data = data {
                        var json: [AnyHashable: Any] = [:]
                        do {
                            json = try JSONSerialization.jsonObject(with: data) as! [AnyHashable: Any]
                        } catch {
                            print("YTKit.Channel failed to serialize JSON response")
                        }
                        
                        var channel = Channel()
                        channel.identifier = identifier
                        channel.title = json["author"] as? String
                        channel.description = json["description"] as? String
                        channel.isAgeRestricted = !(json["isFamilyFriendly"] as? Bool ?? true)
                        channel.totalViews = json["totalViews"] as? Int
                        channel.subscribers = json["subCount"] as? Int
                        channel.url = json["authorUrl"] as? String
                        
                        if let thumbnailArray = json["authorThumbnails"] as? [[String: Any]] {
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
                        
                        if let thumbnailArray = json["authorBanners"] as? [[String: Any]] {
                            channel.banners = Thumbnail(low: "", medium: "", high: "", maxRes: "")
                            for thumbnail in thumbnailArray {
                                let url = thumbnail["url"] as! String
                                let size = thumbnail["width"] as? Int
                                if size == 2560 {
                                    channel.banners?.maxRes = url
                                } else if size == 2120 {
                                    channel.banners?.high = url
                                } else if size == 1060 {
                                    channel.banners?.medium = url
                                } else if size == 512 {
                                    channel.banners?.low = url
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    enum VideoSort: String {
        case popular = "popular"
        case latest = "latest"
        case oldest = "oldest"
    }
    
    static func getChannelVideos(channel: Channel, page: Int, sort: VideoSort, _ completion: @escaping ([Video]) -> Void) {
        getChannelVideos(identifier: channel.identifier, page: page, sort: sort, completion)
    }
    
    static func getChannelVideos(identifier: String?, page: Int, sort: VideoSort, _ completion: @escaping ([Video]) -> Void) {
        if let identifier = identifier {
            let urlString = "\(invidiousURL)/channels/videos/\(identifier)?page=\(page)&videoSort=\(sort.rawValue)"
            URLDataHandler.performHTTPRequest(url: URL(string: urlString)!, method: .get, body: nil, fields: nil) { (data, status, error) in
                if let error = error {
                    print("YTKit.Channel.Videos error: \(error.localizedDescription)")
                } else {
                    if status != 200 {
                        print("YTKit.Channel.Videos request returned status \(status)")
                    }
                    
                    if let data = data {
                        var json: [[AnyHashable: Any]] = []
                        do {
                            json = try JSONSerialization.jsonObject(with: data) as? [[AnyHashable: Any]] ?? []
                        } catch {
                            print("YTKit.Channel.Videos failed to serialize JSON response")
                        }
                        
                        var videos: [Video] = []
                        for json in json {
                            var video = Video(identifier: json["videoId"] as? String)
                            video.channel = Channel()
                            video.title = json["title"] as? String
                            video.channel?.title = json["author"] as? String
                            video.channel?.identifier = json["authorId"] as? String
                            video.description = json["description"] as? String
                            
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
                            
                            videos.append(video)
                        }
                        
                        completion(videos)
                    }
                }
            }
        }
    }
    
    struct Video {
        init() {}
        
        init(identifier: String?) {
            self.identifier = identifier
        }
        
        var identifier: String?
        var title: String?
        var description: String?
        var thumbnails: Thumbnail?
        var length: TimeInterval?
        var likes: Int?
        var dislikes: Int?
        var views: Int?
        var isAgeRestricted: Bool?
        var streamURLs: VideoURLs?
        var videoURLs: VideoURLs?
        var publishDate: Date?
        var channel: Channel?
        var recommendedVideos: [Video]?
        
        enum Fields: String {
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
    }
    
    static func getVideo(identifier: String?, fields: [Video.Fields], _ completion: @escaping (Video) -> Void) {
        if let identifier = identifier {
            var urlString = "\(invidiousURL)/videos/\(identifier)?fields="
            for field in fields {
                urlString.append(field.rawValue)
                urlString.append((field != fields.last) ? "," : "")
            }
            
            URLDataHandler.performHTTPRequest(url: URL(string: urlString)!, method: .get, body: nil, fields: nil) { (data, status, error) in
                if let error = error {
                    print("YTKit.Video error: \(error.localizedDescription)")
                } else {
                    if status != 200 {
                        print("YTKit.Video request returned \(status)")
                    }
                    
                    if let data = data {
                        var json: [AnyHashable: Any] = [:]
                        do {
                            json = try JSONSerialization.jsonObject(with: data) as! [AnyHashable: Any]
                        } catch {
                            print("YTKit.Video failed to serialize JSON response")
                        }
                        
                        var video = Video()
                        video.identifier = identifier
                        video.title = json["title"] as? String
                        video.description = json["description"] as? String
                        video.views = json["viewCount"] as? Int
                        video.likes = json["likeCount"] as? Int
                        video.dislikes = json["dislikeCount"] as? Int
                        video.isAgeRestricted = !(json["isFamilyFriendly"] as? Bool ?? true)
                        video.length = json["lengthSeconds"] as? TimeInterval
                        
                        video.channel = Channel()
                        video.channel?.title = json["author"] as? String
                        video.channel?.identifier = json["authorId"] as? String
                        
                        if let urlArray = json["adaptiveFormats"] as? [[String: Any]] {
                            video.streamURLs = Video.VideoURLs()
                            for url in urlArray {
                                if url["container"] as? String == "mp4" {
                                    if url["qualityLabel"] as? String == "1080p60" {
                                        video.streamURLs!.quality1080p60 = url["url"] as? String
                                    } else if url["qualityLabel"] as? String == "1080p" {
                                        video.streamURLs!.quality1080p = url["url"] as? String
                                    } else if url["qualityLabel"] as? String == "720p60" {
                                        video.streamURLs!.quality720p60 = url["url"] as? String
                                    } else if url["qualityLabel"] as? String == "720p" {
                                        video.streamURLs!.quality720p = url["url"] as? String
                                    } else if url["qualityLabel"] as? String == "480p" {
                                        video.streamURLs!.quality480p = url["url"] as? String
                                    } else if url["qualityLabel"] as? String == "360p" {
                                        video.streamURLs!.quality360p = url["url"] as? String
                                    } else if url["qualityLabel"] as? String == "240p" {
                                        video.streamURLs!.quality240p = url["url"] as? String
                                    } else if url["qualityLabel"] as? String == "144p" {
                                        video.streamURLs!.quality144p = url["url"] as? String
                                    }
                                } else if url["container"] as? String == "m4a" {
                                    video.streamURLs!.audioOnly = url["url"] as? String
                                }
                            }
                        }
                        
                        if let urlArray = json["formatStreams"] as? [[String: Any]] {
                            video.videoURLs = Video.VideoURLs()
                            for url in urlArray {
                                if url["container"] as? String == "mp4" {
                                    print(url["qualityLabel"] as! String)
                                    if url["qualityLabel"] as? String == "1080p60" {
                                        video.videoURLs!.quality1080p60 = url["url"] as? String
                                    } else if url["qualityLabel"] as? String == "1080p" {
                                        video.videoURLs!.quality1080p = url["url"] as? String
                                    } else if url["qualityLabel"] as? String == "720p60" {
                                        video.videoURLs!.quality720p60 = url["url"] as? String
                                    } else if url["qualityLabel"] as? String == "720p" {
                                        video.videoURLs!.quality720p = url["url"] as? String
                                    } else if url["qualityLabel"] as? String == "480p" {
                                        video.videoURLs!.quality480p = url["url"] as? String
                                    } else if url["qualityLabel"] as? String == "360p" {
                                        video.videoURLs!.quality360p = url["url"] as? String
                                    } else if url["qualityLabel"] as? String == "240p" {
                                        video.videoURLs!.quality240p = url["url"] as? String
                                    } else if url["qualityLabel"] as? String == "144p" {
                                        video.videoURLs!.quality144p = url["url"] as? String
                                    }
                                } else if url["container"] as? String == "m4a" {
                                    video.videoURLs!.audioOnly = url["url"] as? String
                                }
                            }
                        }
                        
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
                        
                        if let thumbnailArray = json["authorThumbnails"] as? [[String: Any]] {
                            video.channel?.thumbnails = Thumbnail(low: "", medium: "", high: "", maxRes: "")
                            for thumbnail in thumbnailArray {
                                let size = thumbnail["width"] as? Int
                                let url = thumbnail["url"] as! String
                                if size == 512 {
                                    video.channel?.thumbnails?.maxRes = url
                                } else if size == 176 {
                                    video.channel?.thumbnails?.high = url
                                } else if size == 100 {
                                    video.channel?.thumbnails?.medium = url
                                } else if size == 76 {
                                    video.channel?.thumbnails?.low = url
                                }
                            }
                        }
                        
                        if let videoArray = json["recommendedVideos"] as? [[String: Any]] {
                            video.recommendedVideos = []
                            for item in videoArray {
                                var recommendedVideo = Video(identifier: item["videoId"] as? String)
                                recommendedVideo.title = item["title"] as? String
                                recommendedVideo.channel?.title = item["author"] as? String
                                recommendedVideo.length = item["lengthSeconds"] as? TimeInterval
                                
                                if let thumbnailArray = item["authorThumbnails"] as? [[String: Any]] {
                                    recommendedVideo.channel?.thumbnails = Thumbnail(low: "", medium: "", high: "", maxRes: "")
                                    for thumbnail in thumbnailArray {
                                        let size = thumbnail["width"] as? Int
                                        let url = thumbnail["url"] as! String
                                        if size == 512 {
                                            recommendedVideo.channel?.thumbnails?.maxRes = url
                                        } else if size == 176 {
                                            recommendedVideo.channel?.thumbnails?.high = url
                                        } else if size == 100 {
                                            recommendedVideo.channel?.thumbnails?.medium = url
                                        } else if size == 76 {
                                            recommendedVideo.channel?.thumbnails?.low = url
                                        }
                                    }
                                }
                                
                                video.recommendedVideos?.append(recommendedVideo)
                            }
                        }
                        
                        if let interval = json["published"] as? TimeInterval {
                            video.publishDate = Date(timeIntervalSince1970: interval)
                        } else {
                            video.publishDate = nil
                        }
                        
                        completion(video)
                    }
                }
            }
        }
    }
    
}

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
