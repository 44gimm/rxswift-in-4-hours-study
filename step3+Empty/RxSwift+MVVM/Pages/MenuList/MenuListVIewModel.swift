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
  
  var menuObservable = BehaviorSubject<[Menu]>(value: [])
  
  //  var itemsCount: Int = 0
  lazy var itemCount = menuObservable.map {
    $0.map { $0.count }
      .reduce(0, +)
  }
  //  var totalPrice: PublishSubject<Int> = PublishSubject()
  lazy var totalPrice = menuObservable.map {
    $0.map { $0.price * $0.count }
      .reduce(0, +)
  }
  
  // Subject
  // Observable처럼 subscribe 도 가능하지만 외부에서 값을 통제할 수도 있음
  // PublishSubject 는 받은대로 내려준다
  
  init() {
    let menus: [Menu] = [
      Menu(id: 0, name: "튀김1", price: 100, count: 0),
      Menu(id: 1, name: "튀김1", price: 100, count: 0),
      Menu(id: 2, name: "튀김1", price: 100, count: 0),
      Menu(id: 3, name: "튀김1", price: 100, count: 0)
    ]
    
    menuObservable.onNext(menus)
  }
  
  func clearAllItemSelections() {
    _ = self.menuObservable
      .map { menus in
        menus.map { menu in
          Menu(id: menu.id, name: menu.name, price: menu.price, count: 0)
        }
    }
      .take(1)    // 1번만 수행하는 observable로 만듬
      .subscribe(onNext: {
        self.menuObservable.onNext($0)
      })
  }
  
  func changeCount(item: Menu, amount: Int) {
    _ = self.menuObservable
      .map { menus in
        menus.map { menu in
          if menu.id == item.id {
            return
              Menu(
                id: menu.id,
                name: menu.name,
                price: menu.price,
                count: max(menu.count + amount, 0)
            )
            
          } else {
            return
              Menu(
                id: menu.id,
                name: menu.name,
                price: menu.price,
                count: menu.count
            )
          }
        }
    }
      .take(1)    // 1번만 수행하는 observable로 만듬
      .subscribe(onNext: {
        self.menuObservable.onNext($0)
      })
  }
  
  func onOrder() {
    
  }
}
