//
//  SoundWaveView.swift
//  waveForm
//
//  Created by Charlie Fang on 7/19/15.
//  Copyright (c) 2015 Charlie Fang. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation

let noiseFloor:Float = -50.0


class SoundWaveView: UIView {
    
    var normalImageView:UIImageView!
    var progressImageView:UIImageView!
    var cropNormalView:UIView!
    var cropProgressView:UIView!
    var normalColorDirty:Bool!
    var progressColorDirty:Bool!
    
    
    var  asset:AVURLAsset!
    var normalColor:UIColor!
    var progressColor:UIColor!
    var progress:CGFloat! = 0
    var antialiasingEnabled:Bool!
    
    var generatedNormalImage:UIImage!
    var generatedProgressImage:UIImage!
    
    
    override init(frame: CGRect)  {
        super.init(frame: frame)
        self.commonInit()
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit(){
        normalImageView = UIImageView()
        progressImageView = UIImageView()
        cropNormalView = UIView()
        cropProgressView = UIView()
        
        cropNormalView.clipsToBounds = true
        cropProgressView.clipsToBounds = true
        
        cropNormalView.addSubview(normalImageView)
        cropProgressView.addSubview(progressImageView)
        
        self.addSubview(cropNormalView)
        self.addSubview(cropProgressView)
        
        self.normalColor = UIColor.blueColor()
        self.progressColor = UIColor.redColor()
        
        normalColorDirty = false
        progressColorDirty = false
        
        antialiasingEnabled = false
    }
    
    
    
    class func renderPixelWaveformInContext(context:CGContextRef, halfGraphHeigh:Float, sample:Double, x:CGFloat){
        println(sample)
        var pixelHeight:Float = halfGraphHeigh * Float(( 1 - sample / Double(noiseFloor)))
        
        if( pixelHeight < 0){
            pixelHeight = 0
        }
        CGContextMoveToPoint(context, x, CGFloat(halfGraphHeigh - pixelHeight))
        CGContextAddLineToPoint(context, x, CGFloat(halfGraphHeigh + pixelHeight))
        CGContextStrokePath(context)
    }
    
    class func renderWavefromInContext(context:CGContextRef, asset:AVAsset?, color:UIColor, size:CGSize, antialiasingEnabled:Bool){
         println("here4")
        if(asset != nil ){
             println("here5")
            var pixelRatio:CGFloat = UIScreen.mainScreen().scale
            var widthInPixels:CGFloat = size.width*pixelRatio
            var heightInPixels:CGFloat = size.height*pixelRatio
            
            var error:NSError?
            
            
            var reader:AVAssetReader = AVAssetReader(asset:asset, error:&error)
            var audioTrackArray:NSArray = asset!.tracksWithMediaType(AVMediaTypeAudio)
            
            if(audioTrackArray.count != 0){
                var songTrack:AVAssetTrack = audioTrackArray[0] as! AVAssetTrack
                
                var outputSettingsDict:NSDictionary  = NSDictionary()
                
                outputSettingsDict=[
                    AVFormatIDKey:NSNumber(int:Int32(kAudioFormatLinearPCM)),
                    AVLinearPCMBitDepthKey:NSNumber(int: 16),
                    AVLinearPCMIsBigEndianKey:NSNumber(bool: false),
                    AVLinearPCMIsFloatKey:NSNumber(bool: false),
                    AVLinearPCMIsNonInterleaved:NSNumber(bool: false)]
                
                var output:AVAssetReaderTrackOutput = AVAssetReaderTrackOutput(track: songTrack, outputSettings: outputSettingsDict as [NSObject : AnyObject])
                
                reader.addOutput(output)
                
                var channelCount:UInt32!
                var formatDesc:NSArray = songTrack.formatDescriptions
               
                
                for(var i:Int = 0; i < formatDesc.count; i++){
                    
                    var item:CMAudioFormatDescriptionRef = formatDesc[i] as! CMAudioFormatDescriptionRef
                    let fmtDesc:AudioStreamBasicDescription? = CMAudioFormatDescriptionGetStreamBasicDescription(item).memory
                    
                    
                    //CMAudioFormatDescriptionGetStreamBasicDescription (item);
                    if fmtDesc != nil
                    {
                        channelCount = fmtDesc!.mChannelsPerFrame
                        
                    }
                }
                
                CGContextSetAllowsAntialiasing(context, antialiasingEnabled)
                CGContextSetLineWidth(context, 1.0)
                CGContextSetStrokeColorWithColor(context, color.CGColor)
                CGContextSetFillColorWithColor(context, color.CGColor)
                
                var bytesPreInputSample:UInt32 = 2 * channelCount
                var totalSamples: UInt64 = UInt64(asset!.duration.value)
                var samplesPerPixel:NSInteger = NSInteger(CGFloat(totalSamples)  / widthInPixels)
                samplesPerPixel = samplesPerPixel < 1 ? 1 : samplesPerPixel
                
                reader.startReading()
                
                var halfGraphHeight:Float = Float(heightInPixels) / 2
                var bigSample:Double = 0
                var bigSampleCount:NSInteger = 0
                var data:NSMutableData = NSMutableData(length: 32768)!
                
                var currentX:CGFloat = 0
                
                
                while (reader.status == AVAssetReaderStatus.Reading)
                {
                    var sampleBufferRef:CMSampleBufferRef? = output.copyNextSampleBuffer()
                    
                    if (sampleBufferRef != nil)
                    {
                        var blockBufferRef:CMBlockBufferRef? = CMSampleBufferGetDataBuffer(sampleBufferRef);
                        var bufferLength:size_t = CMBlockBufferGetDataLength(blockBufferRef)
                        
                        if(data.length < bufferLength){
                            data.length = bufferLength
                        }
                        CMBlockBufferCopyDataBytes(blockBufferRef, 0, bufferLength, data.mutableBytes)
                        var samples:UnsafeMutablePointer<Int16> = UnsafeMutablePointer<Int16>(data.mutableBytes)
                        var sampleCount:Int = (Int(bufferLength) / Int(bytesPreInputSample))
                        
                        for(var i:Int = 0; i < sampleCount; i++){
                            
                            var sample:Float32 = Float32(samples.memory)
                            samples = samples.successor()
                           
                            sample = 20.0 * log10 ((sample < 0 ? 0 - sample : sample) / 32767.0)
                            
                            if(sample == -Float.infinity || sample <= -50){
                                sample = -50
                                
                            }else{
                                if(sample >= 0){
                                    sample = 0
                                }
                            }
                            //println(sample)
                            
                            for(var j:Int = 1; j < Int(channelCount); j++){
                                samples = samples.successor()
                            }
                            
                            bigSample += Double(sample)
                            bigSampleCount++
                            
                            if(bigSampleCount == 4*samplesPerPixel){
                                var averageSample:Double = bigSample / Double(bigSampleCount)
                                println(averageSample)
                                
                                renderPixelWaveformInContext(context, halfGraphHeigh: halfGraphHeight, sample: averageSample, x: currentX*4)
                                
                                currentX++
                                bigSample = 0
                                bigSampleCount = 0
                                
                            }
                        }
                        CMSampleBufferInvalidate(sampleBufferRef)
                    }
                }
                
                bigSample = bigSampleCount > 0 ? bigSample / Double(bigSampleCount) : -50
                while(currentX < 450){
                    renderPixelWaveformInContext(context, halfGraphHeigh: halfGraphHeight, sample: bigSample, x: currentX*4)
                    currentX++
                }
                
            }
        }
    }
    
    class func generateWaveformImage(asset:AVAsset, color:UIColor, size:CGSize, antialiasingEnabled:Bool) -> UIImage{
        
        
        var ratio:CGFloat = UIScreen.mainScreen().scale
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(size.width * ratio, size.height * ratio), false, 1);
        
        SoundWaveView.renderWavefromInContext(UIGraphicsGetCurrentContext(), asset: asset, color: color, size: size, antialiasingEnabled: antialiasingEnabled)
        
        var image:UIImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        return image;
    }
    
    
    class func recolorizeImage(image:UIImage, color:UIColor) -> UIImage{
        var imageRect:CGRect = CGRectMake(0, 0, image.size.width, image.size.height)
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        
        var context:CGContextRef = UIGraphicsGetCurrentContext()
        CGContextTranslateCTM(context, 0.0, image.size.height)
        CGContextScaleCTM(context, 1.0, -1.0)
        CGContextDrawImage(context, imageRect, image.CGImage)
        
        color.set()
        
        UIRectFillUsingBlendMode(imageRect, kCGBlendModeSourceAtop)
        var newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func generateWaveforms(){
        
        var rect:CGRect = self.bounds
        println(self.bounds)
        
        if(self.asset != nil){
             println("here1")
            self.generatedNormalImage = SoundWaveView.generateWaveformImage(self.asset, color: self.normalColor, size: CGSizeMake(rect.size.width, rect.size.height), antialiasingEnabled: self.antialiasingEnabled)
            self.normalImageView.image = generatedNormalImage
            normalColorDirty = false
        }
        
        
        
        self.generatedProgressImage = SoundWaveView.recolorizeImage(self.generatedNormalImage, color: UIColor.redColor())
        self.progressImageView.image = generatedProgressImage

        
        
    }
    
    func applyProgressToSubviews(){
        var bs:CGRect = self.bounds
        var progressWidth:CGFloat = bs.size.width * progress
        cropProgressView.frame = CGRectMake(0, 0, progressWidth, bs.size.height);
        cropNormalView.frame = CGRectMake(progressWidth, 0, bs.size.width - progressWidth, bs.size.height);
        normalImageView.frame = CGRectMake(-progressWidth, 0, bs.size.width, bs.size.height);
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var bs:CGRect = self.bounds;
        normalImageView.frame = bs;
        progressImageView.frame = bs;
        
//        // If the size is now bigger than the generated images
//        if (bs.size.width > self.generatedNormalImage.size.width) {
//            self.generatedNormalImage = nil;
//            self.generatedProgressImage = nil;
//        }
        
        self.applyProgressToSubviews()
    }
    
    
    func SetNormalColor(normalColor:UIColor)
    {
       self.normalColor = normalColor
        self.normalColorDirty = true
        self.setNeedsDisplay()
    }
    
    func SetProgressColor(progressColor:UIColor )
    {
        self.progressColor = progressColor;
        self.progressColorDirty = true
        self.setNeedsDisplay()
    }
    
    func SetAsset(asset:AVURLAsset)
    {
        println("here")
        self.asset = asset
        self.generateWaveforms()
    }
    
    func setProgress(progress:CGFloat)
    {
        self.progress = progress;
        self.applyProgressToSubviews()
    }
    
    func GeneratedNormalImage() -> UIImage
    {
        return self.normalImageView.image!
    }
    
    func SetGeneratedNormalImage(generatedNormalImage:UIImage)
    {
        self.normalImageView.image = generatedNormalImage;
    }
    
    func GeneratedProgressImage() -> UIImage
    {
        return self.progressImageView.image!
    }
    
    
    
    
   
}

