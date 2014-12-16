//
//  ServiceViewController.swift
//  CoreBluetooth
//
//  Created by Theodor Brandt on 2014-12-14.
//  Copyright (c) 2014 Theodor Brandt. All rights reserved.
//

import UIKit

class ServiceViewController: UIViewController, BLEServiceDeligate, ChartDelegate {

    var filer:Filehandler? = Filehandler(hostIP:"192.168.1.184",hostPORT:6667);
    
    var service: BLEService!
    
    @IBOutlet var loadingSpinner: UIActivityIndicatorView!

    
    @IBOutlet var labelNumberOfPolls: UILabel!
    
    @IBOutlet var labelAverageValue: UILabel!
    
    @IBOutlet var labelCurrentValue: UILabel!
    
    
    var avarageSum:Float = 0;
    
    var arrayOfValues = [Float]();
    
    @IBOutlet var myChart: Chart!

    var numberofPolls:Int = 0;
    var started:Bool = false;
    
    
    override func viewDidLoad() {
        println("Hello from ServiceViewController")
        service.deligate = self;
        self.arrayOfValues.append(0);
        
        myChart.hidden = true;
        let series = ChartSeries(self.arrayOfValues)
        series.area = true
        
        myChart.addSeries(series)
        
        // Set minimum and maximum values for y-axis
        myChart.minY = -10
        myChart.maxY = 30
        // Format y-axis, e.g. with units
        myChart.yLabelsFormatter = { String(Int($1)) +  "ºC" }
        self.filer?.write("");
        
    }
    
    
    var toggle = true;
    @IBAction func start(sender: AnyObject) {

        
        
        if((sender as UIButton).titleLabel?.text == "Start"){
            // START GETTING DATA
            self.service.startGettingData()
            (sender as UIButton).setTitle("Stop", forState: UIControlState.Normal)
        }else{
            // STOP GETTING DATA 
            self.service.stopGettingData()
            (sender as UIButton).setTitle("Start", forState: UIControlState.Normal)
        }
    }
    
    
    @IBAction func reset(sender: AnyObject) {
        println("reset pressed");
        self.avarageSum = 0;
        self.numberofPolls = 0;
        self.filer?.write("");
        
        self.labelAverageValue.text = "-.-"
        self.labelCurrentValue.text = "-.-"
        self.labelNumberOfPolls.text = "-";

    }
    
    
    
    func didTouchChart(chart: Chart, indexes: Array<Int?>, x: Float, left: CGFloat) {
        for (seriesIndex, dataIndex) in enumerate(indexes) {
            if let value = chart.valueForSeries(seriesIndex, atIndex: dataIndex) {
                println("Touched series: \(seriesIndex): data index: \(dataIndex!); series value: \(value); x-axis value: \(x) (from left: \(left))")
            }
        }
    }
    
    func didFinishTouchingChart(chart: Chart) {
     
        
        
    }
    
    func placeLastAndMove(value:Float){
        
        self.myChart.removeSeries()
        self.arrayOfValues.append(value)
        
        if( self.arrayOfValues.count >= 10){
            self.arrayOfValues.removeAtIndex(0)
        }
        
        if !self.started{
            self.arrayOfValues.removeAtIndex(0)
            self.started = true;
        }
        
        let series = ChartSeries(self.arrayOfValues)
        series.area = true
        
        self.myChart.addSeries(series)
        self.myChart.setNeedsDisplay()
        
        filer?.append("{poll: \(self.numberofPolls) value: \(value)}\n")
        self.numberofPolls++;
    }
    
    override func viewWillAppear(animated: Bool) {
        self.service.discoverServices()
        self.filer = nil;
        self.filer = Filehandler(hostIP:"192.168.1.184",hostPORT:6667);

    }
    
    
    override func viewWillDisappear(animated: Bool) {

        service.stopGettingData()

    }
    
    
    
    func BLEServiceIsFound() {
        //self.service.startGettingData()
        println("can now take data")
        service.startGettingData()
    }
    
    func BLEServiceIsConfigured() {
        
        dispatch_async(dispatch_get_main_queue(), {
        
            self.loadingSpinner.stopAnimating()
            self.myChart.hidden = false;
        });
    }
    
    
    func BLEServiceIRTemperatureHasData(tAmb: Float, tObj: Float) {
            println("Recived data \(tAmb) and \(tObj)")
        
        var recivedValue = tObj;
        dispatch_async(dispatch_get_main_queue(), {

            
            
            if(recivedValue.isNaN){
                recivedValue = (Float(self.avarageSum)/Float(self.numberofPolls))
            }
            
            
            self.labelNumberOfPolls.text = "\(self.numberofPolls)";
            var value = String(format: "%.1f", recivedValue)
            self.labelCurrentValue.text = "\(value)"
            value = String(format: "%.1f", self.calculateAverage(recivedValue))
            self.labelAverageValue.text = "\(value)"
            self.placeLastAndMove(recivedValue);

            
            
            
            });
    }
    
    func calculateAverage(newValue:Float) -> Float{
    
        self.avarageSum += newValue;
        
        return (self.avarageSum/(Float(self.numberofPolls)))
        
    
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println("Changing")
        
        if (segue.identifier == "showSettings") {
            let vc = segue.destinationViewController as SendViewController
            vc.filer = self.filer;
        }
    }
    
}
