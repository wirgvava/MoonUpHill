//
//  WeatherWidget.swift
//  WeatherWidget
//
//  Created by Konstantine Tsirgvava on 03.03.24.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: .now, city: "Tbilisi", bg: "Sunny", conditionImage: "imClear", temperature: 25)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: .now, city: "Tbilisi", bg: "Sunny", conditionImage: "imClear", temperature: 25)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let calendar = Calendar.current
        var entries: [SimpleEntry] = []
        
        var isNight = false
        
        if let currentHour = calendar.dateComponents([.hour], from: currentDate).hour {
            isNight = currentHour > 20 || currentHour < 5 ? true : false
        }

        let defaults = UserDefaultsManager.shared
        let city = defaults.getAppGroupDefaultsString(from: .widgetCity) ?? "Tbilisi"
        let temperature = defaults.getAppGroupDefaultsInt(from: .widgetTemp) ?? 0
        let conditionImage = defaults.getAppGroupDefaultsString(from: .widgetCondition) ?? "isClear"
        let bg = isNight ? "night" : defaults.getAppGroupDefaultsString(from: .widgetBG) ?? "Sunny"
        
        let entry = SimpleEntry(date: .now, city: city, bg: bg, conditionImage: conditionImage,temperature: temperature)
        entries.append(entry)

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let city: String
    let bg: String
    let conditionImage: String
    let temperature: Int
}

struct WeatherWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            Image(entry.bg)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 160, height: 160)
            
            VStack(alignment: .center, spacing: 0.0) {
                Text(entry.city)
                    .font(.custom("Avenir Next", size: 28))
                    .fontWeight(.medium)
                    .foregroundColorBy(entry: entry)
                
                HStack{
                    if entry.bg == "night" {
                        Image(entry.conditionImage).resizable().frame(width: 50, height: 50)
                            .shadow(color: .black, radius: 20, x: 0.0, y: 0.0)
                            .saturation(-1).contrast(1.4)
                    } else {
                        Image(entry.conditionImage)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .shadow(color: .black, radius: 20, x: 0.0, y: 0.0)
                    }
                    
                    Text("\(entry.temperature) °C")
                        .font(.custom("Avenir Next", size: 20))
                        .fontWeight(.bold)
                        .foregroundColorBy(entry: entry)
                }
            }
        }
    }
}

struct WeatherWidget: Widget {
    let kind: String = "WeatherWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                WeatherWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                WeatherWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("MoonUpHill Widget")
        .description("Display weather information.")
        .supportedFamilies([.systemSmall])
    }
}

extension Text {
    func foregroundColorBy(entry: Provider.Entry) -> Text {
        if entry.bg == "Thunder" || entry.bg == "night" {
            return self.foregroundColor(.white)
        } else {
            return self.foregroundColor(.black)
        }
    }
}

extension Image {
    func filterCondition(by entry: Provider.Entry) -> Image {
        if entry.bg == "night" {
            return self.saturation(-1) as! Image
        }
        return self
    }
}

#Preview(as: .systemSmall) {
    WeatherWidget()
} timeline: {
    SimpleEntry(date: .now, city: "London", bg: "Sunny", conditionImage: "imClear", temperature: 25)
    SimpleEntry(date: .now, city: "London", bg: "Rainy", conditionImage: "imRain", temperature: 19)
    SimpleEntry(date: .now, city: "London", bg: "night", conditionImage: "imThunder", temperature: 20)
    SimpleEntry(date: .now, city: "London", bg: "Snowy", conditionImage: "imSnow", temperature: -2)
    SimpleEntry(date: .now, city: "London", bg: "Thunder", conditionImage: "imThunder", temperature: 6)
}
