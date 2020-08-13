//
//  ViewController.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 05/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import RxSwift
import SwiftyJSON
import UIKit

let MEMBER_LIST_URL = "https://my.api.mockaroo.com/members_with_avatar.json?key=44ce18f0"

// rxswift 용도는 비동기적으로 생기는 데이터를 리턴값으로 전달하기 위함이고,
// 나중에생기는데이터(Observable) 라는 타입으로 감싸서 전달한다.
class 나중에생기는데이터<T> {
  private let task: (@escaping (T) -> Void) -> Void
  
  init(task: @escaping (@escaping (T) -> Void) -> Void) {
    self.task = task
  }
  
  func 나중에오면(_ f: @escaping (T) -> Void) {
    task(f)
  }
}


class ViewController: UIViewController {
  @IBOutlet var timerLabel: UILabel!
  @IBOutlet var editView: UITextView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
      self?.timerLabel.text = "\(Date().timeIntervalSince1970)"
    }
  }
  
  private func setVisibleWithAnimation(_ v: UIView?, _ s: Bool) {
    guard let v = v else { return }
    UIView.animate(withDuration: 0.3, animations: { [weak v] in
      v?.isHidden = !s
      }, completion: { [weak self] _ in
        self?.view.layoutIfNeeded()
    })
  }
  
  // Observable의 생명주기
  // 1. create
  // 2. subscribe
  // 3. onNext
  // ---- 끝 -----
  // 여기서부터 Observable 재사용 불가
  // 4. onCompleted / onError
  // 5. disposed
  
  func downloadJson(_ url: String) -> Observable<String?> {
    // 1. 비동기로 생기는 데이터를 Observable로 감싸서 리턴하는 방법
    Observable.create() { emitter in
      let url = URL(string: MEMBER_LIST_URL)!
      let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
        guard error == nil else {
          emitter.onError(error!)
          return
        }
        
        if let data = data, let json = String(data: data, encoding: .utf8) {
          emitter.onNext(json)
        }
        
        emitter.onCompleted() // 클로저가 없어짐 -> 레퍼런스 카운트 감소
      }
      
      task.resume()
      
      return Disposables.create() {
        // dispose 되면 작업 취소
        task.cancel()
      }
    }
    
    // Observable.just -> 한번만 전달
    // Observable.from -> 배열로 받아 배열만큼 전달
    
    //    return Observable.create() { f in
    //      DispatchQueue.global().async {
    //        let url = URL(string: MEMBER_LIST_URL)!
    //        let data = try! Data(contentsOf: url)
    //        let json = String(data: data, encoding: .utf8)
    //
    //        DispatchQueue.main.async {
    //          f.onNext(json)
    ////          f.onCompleted() // 클로저가 없어짐 -> 레퍼런스 카운트 감소
    //        }
    //      }
    //
    //      return Disposables.create()
    //    }
  }
  
  // MARK: SYNC
  
  @IBOutlet var activityIndicator: UIActivityIndicatorView!
  
  @IBAction func onLoad() {
    editView.text = ""
    setVisibleWithAnimation(self.activityIndicator, true)
    
    // 2. Observable로 오는 데이터를 받아서 처리하는 방법
    // observable이 종료되어야(onCompleted, onError, disposed) 클로저가 사라진다.
    
//    _ = downloadJson(MEMBER_LIST_URL)
//      .debug()
//      .subscribe { [weak self] event in
//        switch event {
//        case let .next(json):
//          DispatchQueue.main.async {
//            self?.editView.text = json
//            self?.setVisibleWithAnimation(self?.activityIndicator, false)
//          }
//
//        case .completed, .error:
//          break
//        }
//    }
    
    
    // operator: observable에서 subscribe 사이에 데이터를 처리하는 연산자
    _ = downloadJson(MEMBER_LIST_URL)
      .debug()
      .map { json in json?.count ?? 0 }     // operator
      .filter { count in count > 0 }        // operator
      .map { "\($0)" }                      // operator
      .observeOn(MainScheduler.instance)    // operator DispatchQueue.main.async 처리
      .subscribe(onNext: { [weak self] json in
        self?.editView.text = json
        self?.setVisibleWithAnimation(self?.activityIndicator, false)
      })
    
  }
}
