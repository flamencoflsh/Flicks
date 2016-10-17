//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Jessie Chen on 10/12/16.
//  Copyright © 2016 Jessie Chen. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD
import SystemConfiguration

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    @IBOutlet weak var networkErrorView: UIView!

    @IBOutlet weak var tableView: UITableView!
    
    var movies: [NSDictionary]?
    var endpoint: String!
    let refreshControl = UIRefreshControl()
    var searchBar: UISearchBar!
    var previousSearchTerm = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        searchBar = UISearchBar()
        searchBar.isTranslucent = false
        searchBar.placeholder = "Search"
        
        searchBar.delegate = self
        searchBar.sizeToFit()
        self.navigationItem.titleView = searchBar

        
        navigationController?.navigationBar.barTintColor = UIColor(red: 239.0/255, green: 178.0/255, blue: 68.0/255, alpha: 1.0)
        
        networkErrorView.isHidden = true
        
        if Reachability.isConnectedToNetwork(){
            networkErrorView.isHidden = true
        }else{
            networkErrorView.isHidden = false
        }
        
       fetchData(refresh: false)
        
        
        refreshControl.addTarget(self, action: #selector(refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
        
        tableView.insertSubview(refreshControl, at: 0)
        
        // Do any additional setup after loading the view.
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        
        fetchData(refresh: true)
    }
    
    func fetchData(refresh: Bool){
        
        
        //self.endpoint = "now_playing"
        let endpoint2 = self.endpoint as String
        //let endpoint2 = "now_playing"
        //print(endpoint2)
        
        //let apiKey = "Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV"
        let apiKey = "b41b5fcc7596e309b0751373cf233e57"
        let url = URL(string:"https://api.themoviedb.org/3/movie/\(endpoint2)?api_key=\(apiKey)")
        //print(url!)
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        self.view.backgroundColor = UIColor(red: 239.0/255, green: 178.0/255, blue: 68.0/255, alpha: 1.0)

        
        let task : URLSessionDataTask = session.dataTask(with: request,completionHandler: { (dataOrNil, response, error) in
            if let data = dataOrNil {
                if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options:[]) as? NSDictionary {
                    NSLog("response: \(responseDictionary)")
                    
                    self.movies = responseDictionary["results"] as! [NSDictionary]
                    self.tableView.reloadData()
                    
                    MBProgressHUD.hide(for: self.view, animated: true)
                    
                    if refresh {
                        self.refreshControl.endRefreshing()
                    }
                    
                }
            }
        });
        task.resume()

    }
    
  
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let movies = movies {
            return movies.count
        }else {
            return 0
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
        let baseUrl = "https://image.tmdb.org/t/p/w500"
        
        if let posterPath = movie["poster_path"] as? String
        {
        let posterUrl = NSURL(string: baseUrl + posterPath)
        cell.posterView.setImageWith(posterUrl! as URL)

        }
        
        return cell
    }
    
    
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)
        let movie = movies![indexPath!.row]
        
        let detailViewController = segue.destination as! DetailViewController
        detailViewController.movie = movie
        
        print("prepare for segue called")
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}


public class Reachability {
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
//        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
//            //SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
//            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
//        }
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
}


