//
//  ViewController.swift
//  workout locker
//
//  Created by 김태우 on 2022/01/13.
//

import UIKit
import HealthKit
import HealthKitUI
import SwiftUI

class ViewController: UIViewController {
    
    @IBOutlet weak var tentaAPImissing: UIButton!
    @IBOutlet var missingbtnconst: NSLayoutConstraint!
    @IBSegueAction func ringView(_ coder: NSCoder) -> UIViewController? {
        let hostVC: UIHostingController! = UIHostingController(coder: coder, rootView: HKRing())
        hostVC.view.isOpaque = false
        hostVC.view.backgroundColor = UIColor.clear
        return hostVC
    }
    
    let healthstore = HKHealthStore()
    let alertDispatchQueue = DispatchQueue(label: "Alert")
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tentaAPImissing.alpha = 0
        missingbtnconst.constant = 0
        
        tentaAPImissing.layer.shadowColor = UIColor.gray.cgColor
        tentaAPImissing.layer.shadowOpacity = 1
        tentaAPImissing.layer.shadowOffset = CGSize(width: 0, height: 3)
        
        self.view.layoutIfNeeded()
    }
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Do any additional setup after loading the view.
        if !HKHealthStore.isHealthDataAvailable() {
            let hkNotSupported = UIAlertController(title: "지원 불가", message: "이 기기는 헬스킷을 지원하지 않습니다.", preferredStyle: UIAlertController.Style.alert)
            let ok = UIAlertAction(title: "확인", style: .default) { (action) in }
            
            hkNotSupported.addAction(ok)
            present(hkNotSupported, animated: false, completion: nil)
        }
        
        else {
            var didAuthSuccess: Bool? = nil {
                didSet {
                    if didAuthSuccess! {
                        postworkoutduration()
                    } else {
                        print("Failed to Auth")
                    }
                }
            }
            
            let objectType = Set([HKObjectType.activitySummaryType()])
            self.healthstore.requestAuthorization(toShare: nil, read: objectType) { (success, error) in
                //print(success, error, "HKAuth")
                didAuthSuccess = success
            }
        }
    }
    
    func postworkoutduration() {
        var goal: Double? = nil
        var duration: Double? = nil {
            didSet {
                let tentaAPIAddr: String! = UserDefaults.standard.string(forKey: "tentaAPIAddr")
                
                let url_fore = "https://ptsv2.com/t/"
                //let url = URL(string: "https://ptsv2.com/t/fcvdh-1642097175/post")!
                if tentaAPIAddr == nil || tentaAPIAddr == "" {
                    alertTentaAPIMissing(string: "PTS - V2 주소가 없습니다.")
                    return
                }
                let url_comp = url_fore + tentaAPIAddr + "/post"
                let url = URL(string: url_comp)!
                var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
                
                components.queryItems = [
                    URLQueryItem(name: "time", value: String(duration ?? 90000)),
                    URLQueryItem(name: "goal", value: String(goal ?? 90000))
                ]
                
                let query: String! = components.url!.query
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.httpBody = Data(query.utf8)
                
                let task = URLSession.shared.dataTask(with: request) {
                    data, response, error in
                    
                    if let error = error {
                        //print(error)
                        if error.localizedDescription == "The Internet connection appears to be offline." {}
                        //Not implementing online handler since the app isn't launchable when offline without Apple Developer membership.
                        return
                    }
                    
                    guard let response = response as? HTTPURLResponse,
                          (200...299).contains(response.statusCode) else {
                              print("server error")
                              return
                    }
                }
                task.resume()
            }
        }
        DispatchQueue.global(qos: .default).async {
            goal = self.queryHKSummary().1
            duration = self.queryHKSummary().0
        }
    }
    
    func queryHKSummary() -> (Double?, Double?) {
        let semaphore = DispatchSemaphore(value: 0)
        
        let calendar = Calendar.autoupdatingCurrent
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        dateComponents.calendar = calendar
        
        let predicate = HKQuery.predicateForActivitySummary(with: dateComponents)
        
        var summary_g: HKActivitySummary!
        var exerciseTime: Double?
        var exerciseGoal: Double?
        
        let query = HKActivitySummaryQuery(predicate: predicate) { (query, summary, error) in
            guard let summaries = summary, summaries.count > 0
            else {
                //print(error, "QueryError")
                if error == nil {
                    self.alertTentaAPIMissing(string: "운동 데이터가 없습니다.")
                }
                semaphore.signal()
                return
            }
            
            for summary in summaries {
                summary_g = summary
            }
            
            exerciseTime = summary_g?.appleExerciseTime.doubleValue(for: HKUnit.minute())
            exerciseGoal = summary_g?.appleExerciseTimeGoal.doubleValue(for: HKUnit.minute())
            semaphore.signal()
        }
        
        healthstore.execute(query)
        semaphore.wait()
        
        return (exerciseTime, exerciseGoal)

    }
    
    func alertTentaAPIMissing(string: String?) {
        let moveduration: TimeInterval = 0.6
        let alphaduraion: TimeInterval = 0.2


        DispatchQueue.main.async {
            self.tentaAPImissing.setTitle(string, for: .normal)
            self.missingbtnconst.constant = 35
            UIView.animate(withDuration: moveduration, animations: { self.view.layoutIfNeeded() })
            UIView.animate(withDuration: alphaduraion, animations: { self.tentaAPImissing.alpha = 1.0 }, completion: nil)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
            self.missingbtnconst.constant = 0
            UIView.animate(withDuration: moveduration, animations: { self.view.layoutIfNeeded() })
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                UIView.animate(withDuration: alphaduraion, animations: { self.tentaAPImissing.alpha = 0 }, completion: nil)
            }
        }
        
        if string == "PTS - V2 주소가 없습니다." {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
                self.performSegue(withIdentifier: "seguetosettings", sender: nil)
            }
        }
    }
}
