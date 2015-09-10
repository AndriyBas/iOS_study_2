//
//  ViewController.swift
//  Trax
//
//  Created by Andriy Bas on 9/1/15.
//  Copyright © 2015 Andriy Bas. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, UIPopoverPresentationControllerDelegate {
    
    // MARK: Views
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.mapType = MKMapType.Satellite
            mapView.delegate = self
        }
    }
    
    // MARK: Vars
    var gpxURL: NSURL? {
        didSet {
            if let url = gpxURL {
                GPX.parse(url) {
                    if let gpx = $0 {
                        self.handleWaypoints(gpx.waypoints)
                    }
                }
            }
        }
    }
    
    // MARK: Constants
    private struct Constants {
        static let AnnotationViewReuseIdentifier = "waypoints"
        static let LeftCalloutFrame = CGRect(origin: CGPointZero, size: CGSize(width: 40, height: 40))
        static let ShowImageIdentifier = "showImage"
        static let EditWaypointSegueIdentifier = "Edit Waypoint Identifier"
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let center = NSNotificationCenter.defaultCenter()
        let queue = NSOperationQueue.mainQueue()
        let appDelegate = UIApplication.sharedApplication().delegate
        
        center.addObserverForName(GPXURL.Notification,
            object: appDelegate,
            queue: queue) { notification in
                if let url = notification.userInfo?[GPXURL.FileURLKey] as? NSURL {
                    self.gpxURL = url
                    NSLog("Received \(url)")
                }
        }
        
        self.gpxURL = NSURL(string: "http://cs193p.stanford.edu/Vacation.gpx")
    }

    //MARK: IBActions
    
    @IBAction func addWaypoint(sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Began {
            let coordinate = mapView.convertPoint(sender.locationInView(mapView), toCoordinateFromView: mapView)
            let waypoint = EditableWaypoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
            waypoint.name = "Dropped"
            waypoint.links.append(GPX.Link(href: "http://cs193p.stanford.edu/Images/Panorama.jpg"))
            mapView.addAnnotation(waypoint)
        }
    }

    // MARK: MKMapView - Waypoints
    
    private func clearWaypoints() {
        if mapView?.annotations != nil {
            mapView.removeAnnotations(mapView.annotations)
        }
    }
    
    private func handleWaypoints(waypoints: [GPX.Waypoint]) {
        mapView.addAnnotations(waypoints)
        mapView.showAnnotations(waypoints, animated: true)
    }
    
    // MARK: MKMapViewDelegate
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var view = mapView.dequeueReusableAnnotationViewWithIdentifier(Constants.AnnotationViewReuseIdentifier)
        
        if (view == nil) {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Constants.AnnotationViewReuseIdentifier)
            view?.canShowCallout = true
        } else {
            view?.annotation = annotation
        }
        
        view?.draggable = annotation is EditableWaypoint
        
        view?.leftCalloutAccessoryView = nil
        view?.rightCalloutAccessoryView = nil
        if let waypoint = annotation as? GPX.Waypoint {
            if waypoint.thumbnailURL != nil {
                view?.leftCalloutAccessoryView = UIButton(frame: Constants.LeftCalloutFrame)
            }
            if waypoint is EditableWaypoint {
                view?.rightCalloutAccessoryView = UIButton(type: UIButtonType.DetailDisclosure)
            }
        }
        
        return view
    }
    
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if let waypoint = view.annotation as? GPX.Waypoint {
            if let thumbnailImageButton = view.leftCalloutAccessoryView as? UIButton {
                if let imageData = NSData(contentsOfURL: waypoint.thumbnailURL!) { //FIXME blocks main thread!!!
                    if let image = UIImage(data: imageData) {
                        thumbnailImageButton.setImage(image, forState: UIControlState.Normal)
                    }
                }
            }
        }
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if (control as? UIButton)?.buttonType == UIButtonType.DetailDisclosure {
            mapView.deselectAnnotation(view.annotation, animated: false)
            performSegueWithIdentifier(Constants.EditWaypointSegueIdentifier, sender: view)
        } else if let waypoint = view.annotation as? GPX.Waypoint {
            if waypoint.imageURL != nil {
                performSegueWithIdentifier(Constants.ShowImageIdentifier, sender: view)
            }
        }
    }
    
    // MARK: UIPopoverPresentationControllerDelegate
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.OverFullScreen
    }
    
    func presentationController(controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        
        let nav = UINavigationController(rootViewController: controller.presentedViewController)
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.ExtraLight))
        visualEffectView.frame = nav.view.bounds
        nav.view.insertSubview(visualEffectView, atIndex: 0)
        
        return nav
    }
    
    //MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if Constants.ShowImageIdentifier == segue.identifier {
            if let waypoint = (sender as? MKAnnotationView)?.annotation as? GPX.Waypoint {
                if let vc = segue.destinationViewController.contentViewController as? ImageViewController {
                    vc.imageURL = waypoint.imageURL
                    vc.title = waypoint.name
                }
            }
        } else if Constants.EditWaypointSegueIdentifier == segue.identifier {
            if let waypoint = (sender as? MKAnnotationView)?.annotation as? EditableWaypoint {
                if let vc = segue.destinationViewController.contentViewController as? EditWaypointsViewController {
                    if let ppc = vc.popoverPresentationController {
                        let coordinatePoint = mapView.convertCoordinate(waypoint.coordinate, toPointToView: mapView)
                        ppc.sourceRect = (sender as! MKAnnotationView).popoverSourceRectForCoordinatePoint(coordinatePoint)
                        let minSize = vc.view.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
                        vc.preferredContentSize = CGSize(width: CGFloat(320), height: minSize.height)
                        
                        ppc.delegate = self
                        
                    }
                    vc.waypoint = waypoint
                }
            }
        }
    }
    
}

extension UIViewController {
    var contentViewController: UIViewController? {
        if let vc = self as? UINavigationController {
            return vc.visibleViewController
        } else {
            return self
        }
    }
}

extension MKAnnotationView {
    func popoverSourceRectForCoordinatePoint(coordinatePoint: CGPoint) -> CGRect {
        var centerRect = coordinatePoint
        centerRect.x -= frame.width / 2 - centerOffset.x - calloutOffset.x
        centerRect.y -= frame.height / 2 - centerOffset.y - calloutOffset.y
        return CGRect(origin: centerRect, size: frame.size)
    }
}



