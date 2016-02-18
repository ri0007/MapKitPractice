//
//  ViewController.swift
//  MapKitPractice
//
//  Created by 井上 龍一 on 2016/02/18.
//  Copyright © 2016年 Ryuichi Inoue. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

//シュミレーター上でMapの拡大縮小は、Optionを押しながらトラックパッドを操作することで可能

//Info.plistの編集
//  Key: NSLocationAlwaysUsageDescription
//  Type: String
//  Value: Use CoreLocation!

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    //MapViewの生成
    let myMapView = MKMapView()
    
    //LocationManagerの生成（viewDidLoadの外に指定してあげることで、デリゲートメソッドの中でもmyLocationManagerを使用できる）
    let myLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ここからがMapView生成の処理
        //.frameでサイズと位置を指定する
        myMapView.frame = self.view.frame
        self.view.addSubview(myMapView)
        
        //長押しを探知する機能を追加
        let longTapGesture = UILongPressGestureRecognizer()
        longTapGesture.addTarget(self, action: "longPressed:")
        myMapView.addGestureRecognizer(longTapGesture)
        
        //デリゲートを設定
        myMapView.delegate = self
        
        //これで何もしなくても現在位置が青丸(MKUserLocation)で表示されます。
        myMapView.showsUserLocation = true
        
        //ここからが現在地取得の処理
        myLocationManager.delegate = self
        
        // セキュリティ認証のステータスを取得
        let status = CLLocationManager.authorizationStatus()
        if status == CLAuthorizationStatus.NotDetermined {
            // まだ承認が得られていない場合は、認証ダイアログを表示
            myLocationManager.requestAlwaysAuthorization()
        }
        // 位置情報の更新を開始
        myLocationManager.startUpdatingLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //長押しした時にピンを置く処理
    func longPressed(sender: UILongPressGestureRecognizer) {
        
        //この処理を書くことにより、指を離したときだけ反応するようにする（何回も呼び出されないようになる。最後の話したタイミングで呼ばれる）
        if sender.state != UIGestureRecognizerState.Began {
            return
        }
        
        //senderから長押しした地図上の座標を取得
        let  tappedLocation = sender.locationInView(myMapView)
        let tappedPoint = myMapView.convertPoint(tappedLocation, toCoordinateFromView: myMapView)
        
        //ピンの生成
        let pin = MKPointAnnotation()
        //ピンを置く場所を指定
        pin.coordinate = tappedPoint
        //ピンのタイトルを設定
        pin.title = "タイトル"
        //ピンのサブタイトルの設定
        pin.subtitle = "サブタイトル"
        //ピンをMapViewの上に置く
        self.myMapView.addAnnotation(pin)
    }
    
    // GPSから値を取得した際に呼び出されるメソッド
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // 配列から現在座標を取得（配列locationsの中から最新のものを取得する）
        let myLocation = locations.last! as CLLocation
        //Pinに表示するためにはCLLocationCoordinate2Dに変換してあげる必要がある
        let currentLocation = myLocation.coordinate
        
        
        //ここでピンの追加を行うと、位置情報を取得するたびにピンが追加されてしまう
        /*
        //ピンの生成と配置
        let pin = MKPointAnnotation()
        pin.coordinate = currentLocation
        pin.title = "現在地"
        self.myMapView.addAnnotation(pin)
        */
        
        //アプリ起動時の表示領域の設定
        //delta数字を大きくすると表示領域も広がる。数字を小さくするとより詳細な地図が得られる。
        let mySpan = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let myRegion = MKCoordinateRegionMake(currentLocation, mySpan)
        myMapView.region = myRegion
    }
    
    
    //このMKMapViewDelegateのメソッドでアノテーションの外観を表すannotationViewを返すことで各アノテーションの外観を設定できる
    //なお、MKPinAnnotationViewのアニメーションやドラッグを有効にするのはここで行うと良い
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        //このようにuserLocationのピン(つまり現在位置)を除外しないと
        //青丸(MKUserLocation)であるはずの現在位置まで他のピンと同様の外観になるので注意
        if annotation as? MKUserLocation == mapView.userLocation {
            return nil
        }
        
        //UITableView等と同様にピンも再利用する
        var annotationView = myMapView.dequeueReusableAnnotationViewWithIdentifier("annotation") as? MKPinAnnotationView
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
        }
        
        //アニメーションするか
        annotationView?.animatesDrop = true
        
        //バルーン(タップされた時に出るアレ)を表示させるか
        annotationView?.canShowCallout = true
        
        //ドラッグ可能にするか
        annotationView?.draggable = true
        
        return annotationView
    }
    
    //GPSの取得に失敗したときの処理
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    //認証状態を確認するだけなので、ここの処理はなくてもOK
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        // 認証のステータスをログで表示.
        var statusStr = ""
        switch (status) {
        case .NotDetermined:
            statusStr = "NotDetermined"
        case .Restricted:
            statusStr = "Restricted"
        case .Denied:
            statusStr = "Denied"
        case .AuthorizedAlways:
            statusStr = "AuthorizedAlways"
        case .AuthorizedWhenInUse:
            statusStr = "AuthorizedWhenInUse"
        }
        print(" CLAuthorizationStatus: \(statusStr)")
        
    }
}


