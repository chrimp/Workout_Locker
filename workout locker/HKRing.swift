//
//  HKRing.swift
//  workout locker
//
//  Created by 김태우 on 2022/01/16.
//

import SwiftUI
import HealthKit
import HealthKitUI

struct ActivityRingView: UIViewRepresentable {
    
    var activitySummary: HKActivitySummary
    
    func makeUIView(context: Context) -> HKActivityRingView {
        let frame = CGRect(x: 0, y: 0, width: 240, height: 240)
        let hkView = HKActivityRingView(frame: frame)
        
        let sublys: [CALayer]! = hkView.layer.sublayers
        var asub: CALayer!
        for subly in sublys {
            asub = subly
        }
        asub?.backgroundColor = CGColor(gray: 1, alpha: 0)
        return hkView
    }
    
    func updateUIView(_ uiView: HKActivityRingView, context: Context) {
        uiView.activitySummary = self.activitySummary
    }
}

struct HKRing: View {
    let healthstore = HKHealthStore()

    var body: some View {
    
        VStack {
            ActivityRingView(activitySummary: queryHKSummary())
                .frame(width: 240, height: 240)
        }
        .background(Color(uiColor: UIColor(white: 1, alpha: 0)))
    }

    func queryHKSummary() -> HKActivitySummary {
        let semaphore = DispatchSemaphore(value: 0)
        
        let calendar = Calendar.autoupdatingCurrent
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        dateComponents.calendar = calendar
        
        let predicate = HKQuery.predicateForActivitySummary(with: dateComponents)
        
        var summary_g: HKActivitySummary!
        
        let query = HKActivitySummaryQuery(predicate: predicate) { (query, summary, error) in
            guard let summaries = summary, summaries.count > 0
            else {
                //print(error, "error")
                semaphore.signal()
                return
            }
            
            for summary in summaries {
                summary_g = summary
            }
            semaphore.signal()
        }
        
        healthstore.execute(query)
        semaphore.wait()
        
        return summary_g ?? HKActivitySummary()
        /*let s = HKActivitySummary()
        s.activeEnergyBurnedGoal = HKQuantity(unit: HKUnit(from: .kilocalorie), doubleValue: 400)
        s.activeEnergyBurned = HKQuantity(unit: HKUnit(from: .kilocalorie), doubleValue: 750)
        s.appleExerciseTimeGoal = HKQuantity(unit: HKUnit.minute(), doubleValue: 30)
        s.appleExerciseTime = HKQuantity(unit: HKUnit.minute(), doubleValue: 20)
        s.appleStandHoursGoal = HKQuantity(unit: HKUnit.count(), doubleValue: 12)
        s.appleStandHours = HKQuantity(unit: HKUnit.count(), doubleValue: 15)
        return s*/
    }
}

struct HKRing_Previews: PreviewProvider {
    static var previews: some View {
        HKRing()
    }
}
