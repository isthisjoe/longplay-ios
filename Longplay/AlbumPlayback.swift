

class AlbumPlayback:NSObject {
    
    var album:SPTAlbum?
    var trackURIs:Array<NSURL> = []
    var trackDurations:Array<NSTimeInterval> = []
    var totalDuration:NSTimeInterval = 0
    var currentAlbumPlaybackPosition:NSTimeInterval = 0
    var previousPlaybackPosition:NSTimeInterval = 0
    var progress:Float {
        get {
            return Float(currentAlbumPlaybackPosition)/Float(totalDuration)
        }
    }
    private var kvoContext: UInt8 = 1
    var progressCallback:((progress:Float)->())?
    
    convenience init(album:SPTAlbum) {
        self.init()
        self.album = album
        calculateAlbumPlaybackData()
        currentAlbumPlaybackPosition = 0
    }
    
    func calculateAlbumPlaybackData() {
        if let
            album = album,
            listPage:SPTListPage = album.firstTrackPage,
            let items = listPage.items as? [SPTPartialTrack] {
                for item:SPTPartialTrack in items {
                    if let playableUri = item.playableUri {
                        trackURIs.append(playableUri)
                    }
                    trackDurations.append(item.duration)
                    totalDuration += item.duration
                }
        }
        NSLog("trackDurations: %@", trackDurations)
        NSLog("totalDuration: %f", totalDuration)
    }
    
    func observeAudioStreamingController(controller: SPTAudioStreamingController) {
        //        let options = NSKeyValueObservingOptions([.New, .Old])
        controller.addObserver(self, forKeyPath: "currentPlaybackPosition", options:nil, context: &kvoContext)
        controller.addObserver(self, forKeyPath: "currentTrackIndex", options:nil, context: &kvoContext)
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if context == &kvoContext {
            if keyPath == "currentPlaybackPosition" {
                if let player = object as? SPTAudioStreamingController {
                    if player.currentPlaybackPosition > 0.0 {
                        if previousPlaybackPosition == 0 {
                            previousPlaybackPosition = player.currentPlaybackPosition
                            currentAlbumPlaybackPosition += player.currentPlaybackPosition
                            NSLog("%f %f %f", currentAlbumPlaybackPosition, player.currentPlaybackPosition, previousPlaybackPosition)
                        } else {
                            let delta:NSTimeInterval = player.currentPlaybackPosition - previousPlaybackPosition
                            currentAlbumPlaybackPosition += delta
                            NSLog("%f %f %f", currentAlbumPlaybackPosition, player.currentPlaybackPosition, previousPlaybackPosition)
                            previousPlaybackPosition = player.currentPlaybackPosition
                        }
                    } else {
                        NSLog("%f %f %f", currentAlbumPlaybackPosition, player.currentPlaybackPosition, previousPlaybackPosition)
                    }
                }
            }
            else if keyPath == "currentTrackIndex" {
                if let player = object as? SPTAudioStreamingController {
                    NSLog("currentTrackIndex: %d", player.currentTrackIndex)
                }
                previousPlaybackPosition = 0
            }
//            NSLog("progress: %f", progress)
            if let progressCallback = progressCallback {
                progressCallback(progress: progress)
            }
        }
    }
}