//
//  MenuListVIewModel.swift
//  RxSwift+MVVM
//
//  Created by 44gimm on 2020/08/14.
//  Copyright © 2020 iamchiwon. All rights reserved.
//

import Foundation
import RxSwift

class MenuListViewModel {
  
  var menus: [Menu] = [
    Menu(name: "튀김1", price: 100, count: 0),
    Menu(name: "튀김1", price: 100, count: 0),
    Menu(name: "튀김1", price: 100, count: 0),
    Menu(name: "튀김1", price: 100, count: 0)
  ]
  
  var itemsCount: Int = 0
  var totalPrice: PublishSubject<Int> = PublishSubject()
  
  // Subject
  // Observable처럼 subscribe 도 가능하지만 외부에서 값을 통제할 수도 있음
  // PublishSubject 는 받은대로 내려준다
}
