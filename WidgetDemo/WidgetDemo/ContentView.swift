//
//  ContentView.swift
//  WidgetDemo
//
//  Created by 王锐 on 2021/3/23.
//

import SwiftUI

public let group = "group.com.wangrui.widget"

// 感谢： https://www.jianshu.com/p/94a98c203763
struct ContentView: View {
    var body: some View {
        VStack {
            Text("Hello, world!")
                .padding()
            
            Button(action: {
                self.saveData()
            }, label: {
                Text("Button")
            })
        }
    }
    
    func saveData() {
        //存数据
        let userDefaults = UserDefaults(suiteName: group)
        let data = "一个大西瓜"
        userDefaults?.setValue(data, forKey: "widget")
        userDefaults?.synchronize()
        print("已经存好数据：\(data)")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
