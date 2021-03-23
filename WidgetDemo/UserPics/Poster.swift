//
//  Poster.swift
//  WidgetDemo
//
//  Created by 王锐 on 2021/3/23.
//

import SwiftUI
import UIKit

struct Poster {
    let author: String
    let content: String
    var posterImage: UIImage? = UIImage(named: "222")
}


struct PosterData {
    static func getTodayPoster(completion: @escaping (Result<Poster, Error>) -> Void) {
        let url = URL(string: "https://nowapi.navoinfo.cn/get/now/today")!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error==nil else{
                completion(.failure(error!))
                return
            }
            let poster = posterFromJson(fromData: data!)
            completion(.success(poster))
        }
        task.resume()
    }
    
    static func posterFromJson(fromData data:Data) -> Poster {
        let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        guard let result = json["result"] as? [String: Any] else{
            return Poster(author: "Now", content: "加载失败")
        }
        
        let author = result["author"] as! String
        var content = result["celebrated"] as! String
        let posterImage = result["poster_image"] as! String
        
//        content = "\(content) \(date2String(Date()))"
        content = content + date2String(Date())
        
        if let groupData = getGroupData() {
            content = groupData
            print("已经取到数据: \(content)")
        }
        
        //图片同步请求
        var image: UIImage? = nil
        if let imageData = try? Data(contentsOf: URL(string: posterImage)!) {
            image = UIImage(data: imageData)
        }
        
        return Poster(author: author, content: content, posterImage: image)
    }
    
    static func date2String(_ date: Date, dateFormat: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.init(identifier: "zh_CN")
        formatter.dateFormat = dateFormat
        let date = formatter.string(from: date)
        return date
    }
    
    static func getGroupData() -> String? {
        let userDefaults = UserDefaults(suiteName: "group.com.wangrui.widget")
        return userDefaults?.value(forKey: "widget") as? String
    }
}
