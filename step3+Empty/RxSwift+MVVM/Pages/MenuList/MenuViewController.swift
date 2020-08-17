//
//  ViewController.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 05/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MenuViewController: UIViewController {
  // MARK: - Life Cycle
  
  let viewModel = MenuListViewModel()
  var disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.viewModel.menuObservable
      .bind(to: self.tableView.rx.items(cellIdentifier: "MenuItemTableViewCell", cellType: MenuItemTableViewCell.self)) { index, item, cell in

        cell.title.text = item.name
        cell.price.text = "\(item.price)"
        cell.count.text = "\(item.count)"
        cell.onChange = { [weak self] amount in
          self?.viewModel.changeCount(item: item, amount: amount)
        }
    }
    .disposed(by: self.disposeBag)
    
    self.viewModel.itemCount
      .map { "\($0)" }
//      .catchErrorJustReturn("")               // 에러가 발생한 경우 빈문자열을 리턴한다
//      .observeOn(MainScheduler.instance)      // ui 처리 시 매번 필요하다
//      .subscribe(onNext: { [weak self] in
//        self?.itemCountLabel.text = $0
//      })
//      .bind(to: self.itemCountLabel.rx.text)  // subscribe 하지 않아도 데이터 바인딩 처리, weak 없어도 내부적으로 처리
      .asDriver(onErrorJustReturn: "")          // ui 처리 시 매번 처리하는 작업이 불편하니 driver 로 변경
      .drive(self.itemCountLabel.rx.text)       // driver 가 되면 subscrive 나 bind가 아니라 drive, drive 는 항상 메인스레드에서 돌아간다.
      .disposed(by: self.disposeBag)
    
    self.viewModel.totalPrice
      .map { $0.currencyKR() }
      .observeOn(MainScheduler.instance)
//      .subscribe(onNext: { [weak self] in
//        self?.totalPrice.text = $0
//      })
      .bind(to: self.totalPrice.rx.text)
      .disposed(by: self.disposeBag)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let identifier = segue.identifier ?? ""
    if identifier == "OrderViewController",
      let orderVC = segue.destination as? OrderViewController {
      // TODO: pass selected menus
    }
  }
  
  func showAlert(_ title: String, _ message: String) {
    let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alertVC.addAction(UIAlertAction(title: "OK", style: .default))
    present(alertVC, animated: true, completion: nil)
  }
  
  // MARK: - InterfaceBuilder Links
  
  @IBOutlet var activityIndicator: UIActivityIndicatorView!
  @IBOutlet var tableView: UITableView!
  @IBOutlet var itemCountLabel: UILabel!
  @IBOutlet var totalPrice: UILabel!
  
  @IBAction func onClear() {
    self.viewModel.clearAllItemSelections()
  }
  
  @IBAction func onOrder(_ sender: UIButton) {
    // TODO: no selection
    // showAlert("Order Fail", "No Orders")
//    performSegue(withIdentifier: "OrderViewController", sender: nil)
    
//    self.viewModel.totalPrice.onNext(100)
    
//    self.viewModel.menuObservable.onNext([
//      Menu(id: 0, name: "changed", price: Int.random(in: 100...1000), count: Int.random(in: 0...3)),
//      Menu(id: 1, name: "changed", price: Int.random(in: 100...1000), count: Int.random(in: 0...3)),
//      Menu(id: 2, name: "changed", price: Int.random(in: 100...1000), count: Int.random(in: 0...3))
//    ])
    
    self.viewModel.onOrder()
  }
  
}

//extension MenuViewController: UITableViewDataSource {
//  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//    return self.viewModel.menus.count
//  }
//
//  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//    let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemTableViewCell") as! MenuItemTableViewCell
//
//    let menu = self.viewModel.menus[indexPath.row]
//    cell.title.text = menu.name
//    cell.price.text = "\(menu.price)"
//    cell.count.text = "\(menu.count)"
//
//    return cell
//  }
//}
