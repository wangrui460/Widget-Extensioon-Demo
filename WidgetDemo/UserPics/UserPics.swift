//
//  UserPics.swift
//  UserPics
//
//  Created by 王锐 on 2021/3/23.
//

import WidgetKit
import SwiftUI

// 感谢： https://www.jianshu.com/p/94a98c203763

struct Provider: TimelineProvider {
    // 占位视图
    func placeholder(in context: Context) -> SimpleEntry {
        // 提供一个默认的视图，例如网络请求失败、发生未知错误、第一次展示小组件都会展示这个view
        SimpleEntry(date: Date(), poster: Poster(author: "韦德", content: "你大爷永远是你大爷"))
    }

    // 编辑屏幕在左上角选择添加Widget、第一次展示时会调用该方法
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        // 为了在小部件库中显示小部件，WidgetKit要求提供者提供预览快照，在组件的添加页面可以看到效果
        let entry = SimpleEntry(date: Date(), poster: Poster(author: "韦德", content: "你大爷永远是你大爷"))
        completion(entry)
    }

    // 进行数据的预处理，转化成Entry
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // 在这个方法内可以进行网络请求，拿到的数据保存在对应的entry中，调用completion之后会到刷新小组件
        
//        var entries: [SimpleEntry] = []
//
//        let currentDate = Date()
//
//        for hourOffset in 0 ..< 5 {
//            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
//            let entry = SimpleEntry(date: entryDate)
//            entries.append(entry)
//        }
        
        let currentDate = Date()
        // 设定1小时更新一次数据
        let updateDate = Calendar.current.date(byAdding: .second, value: 5, to: currentDate)!
        
        PosterData.getTodayPoster { result in
            let poster: Poster
            if case .success(let fetchData) = result {
                poster = fetchData
            } else {
                poster = Poster(author: "韦德", content: "你大爷永远是你大爷")
            }
            
            let entry = Entry(date: currentDate, poster: poster)
            let timeline = Timeline(entries: [entry], policy: .after(updateDate))
            completion(timeline)
        }

        // 参数policy：刷新的时机
        // .never：不刷新
        // .atEnd：Timeline 中最后一个 Entry 显示完毕之后自动刷新。Timeline 方法会重新调用
        // .after(date)：到达某个特定时间后自动刷新
        // Widget 刷新的时间由系统统一决定，如果需要强制刷新Widget，可以在 App 中使用 WidgetCenter 来重新加载所有时间线：WidgetCenter.shared.reloadAllTimelines()
        // warning: Timeline的刷新策略是会延迟的，并不一定根据你设定的时间精确刷新。同时官方说明了每个widget窗口小部件每天接收的刷新都会有数量限制
//        let timeline = Timeline(entries: entries, policy: .atEnd)
//        completion(timeline)
    }
}

// 渲染 Widget 所需的数据模型，需要遵守TimelineEntry协议。
struct SimpleEntry: TimelineEntry {
    let date: Date
    let poster: Poster
}

// MARK: 组件view
// 屏幕上 Widget 显示的内容，可以针对不同尺寸的 Widget 设置不同的 View
struct UserPicsEntryView : View {
    var entry: Provider.Entry
    
    //针对不同尺寸的 Widget 设置不同的 View
    @Environment(\.widgetFamily) var family // 尺寸环境变量

    // 不使用@ViewBuilder时你只能传递一个View在闭包里，使用@ViewBuilder你可以传递多个View到闭包里面
    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall:
            // 小尺寸
            ZStack {
                Image(uiImage: entry.poster.posterImage!)
                    .resizable()
                    .frame(minWidth: 169, maxWidth: .infinity, minHeight: 169, maxHeight: .infinity)
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                Text(entry.poster.content)
                    .foregroundColor(.white)
                    .lineLimit(4)
                    .font(.system(size: 14))
                    .padding(.horizontal)
            }
            // systemSmall只能用widgetURL实现URL传递接收
            // systemMedium、systemLarge可以用Link或者widgetUrl处理
            .widgetURL(URL(string: "aaaaaaa"))
        case .systemMedium:
            // 中尺寸
            ZStack {
                MyMediumView(entry: entry)
            }
            .foregroundColor(.white)
            .background(
                        Image("111")
                            .resizable()
                            .edgesIgnoringSafeArea(.all)
                            .scaledToFill()
                    )
        default:
            // 大尺寸
            ZStack {
                MyBigView(entry: entry)
            }
            .padding(.vertical, 15)
            .foregroundColor(.white)
            .background(Color.blue.opacity(0.6))
        }
    }
}

// @main: 代表着Widget的主入口，系统从这里加载，可用于多Widget实现
@main
struct UserPics: Widget {
    // kind: 是Widget的唯一标识
    let kind: String = "UserPics"

    // WidgetConfiguration：初始化配置代码
    var body: some WidgetConfiguration {
        // StaticConfiguration : 可以在不需要用户任何输入的情况下自行解析，可以在 Widget 的 App 中获 取相关数据并发送给 Widget
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            UserPicsEntryView(entry: entry)
        }
        // configurationDisplayName：添加编辑界面展示的标题
        .configurationDisplayName("My Widget")
        // 添加编辑界面展示的描述内容
        .description("This is an example widget.")
        // 设置Widget支持的控件大小，不设置则默认三个样式都实现
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        
        // IntentConfiguration： 主要针对于具有用户可配置属性的Widget，依赖于 App 的 Siri Intent，会自动接收这些 Intent 并用于更新 Widget，用于构建动态 Widget
    }
}

struct UserPics_Previews: PreviewProvider {
    static var previews: some View {
        UserPicsEntryView(
            entry: SimpleEntry(date: Date(),poster: Poster(author: "韦德", content: "你大爷永远是你大爷")))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        UserPicsEntryView(
            entry: SimpleEntry(date: Date(),poster: Poster(author: "韦德", content: "你大爷永远是你大爷")))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        UserPicsEntryView(
            entry: SimpleEntry(date: Date(),poster: Poster(author: "韦德", content: "你大爷永远是你大爷")))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}

struct MyMediumView: View {
    var entry: Provider.Entry
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                Text("晴 16°")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(entry.date, style: .time)
                    .font(.system(size: 14))
                
                Text("去支付宝查看")
                    .font(.system(size: 14))
            }
            .padding(.leading, 15)
            
            Spacer()
            
            VStack(spacing: 8) {
                HStack {
                    Link(destination: URL(string: "pic://sys")!, label: {
                        MiddleButton(title: "扫一扫", imgName: "444")
                    })
                    
                    Link(destination: URL(string: "pic://pay")!, label: {
                        MiddleButton(title: "收/付款", imgName: "444")
                    })
                }
                HStack {
                    Link(destination: URL(string: "pic://go")!, label: {
                        MiddleButton(title: "出行", imgName: "444")
                    })
                    
                    Link(destination: URL(string: "pic://health")!, label: {
                        MiddleButton(title: "健康码", imgName: "444")
                    })
                }
            }
            .padding(.trailing, 15)
        }
    }
}

struct MiddleButton: View {
    let title: String
    let imgName: String
    var body: some View {
        Button(action: {}, label: {
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(.white)
                .fontWeight(.semibold)
        }).background(
            Image(imgName)
                .resizable()
                .frame(width: 60, height: 60)
                .cornerRadius(8))
        .frame(width: 60, height: 60)
    }
}

struct MyBigView: View {
    var entry: Provider.Entry
    var body: some View {
        VStack(spacing: 12) {
            MyMediumView(entry: entry)
            
            Spacer()
            
            Text(entry.poster.content)
                .lineLimit(1)
                .padding(.horizontal)
            Text(entry.poster.content)
                .lineLimit(1)
                .padding(.horizontal)
            Text(entry.poster.content)
                .lineLimit(1)
                .padding(.horizontal)
            Text(entry.poster.content)
                .lineLimit(1)
                .padding(.horizontal)
            Text(entry.poster.content)
                .lineLimit(1)
                .padding(.horizontal)
        }
    }
}
