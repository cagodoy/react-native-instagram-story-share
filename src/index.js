import {
  NativeModules,
  Linking,
} from 'react-native'
const {RNInstagramStoryShare} = NativeModules

const share = options => {
  return new Promise((resolve, reject) => {
    const {appId, provider, backgroundImage, backgroundVideo, stickerImage, backgroundTopColor, backgroundBottomColor, contentURL} = options

    if (!appId && !provider && !backgroundImage && !backgroundVideo && !stickerImage && !backgroundTopColor && !backgroundBottomColor && !contentURL) {
      return reject(new Error('all params are undefined'))
    }

    //TODO(ca): check if FacebookAppID is present in Info.plist
    if (provider !== 'facebook' && provider !== 'instagram') {
      return reject(new Error('provider: invalid param'))
    }
    
    if (provider === 'facebook' && !appId) {
      return reject(new Error('appId: missing param'))
    }
    
    if (provider === 'facebook'  && typeof appId !== 'string') {
      return reject(new Error('appId: invalid param'))
    }

    if (backgroundImage && backgroundVideo) {
      return reject(new Error('it must be just one, backgroundImage or backgroundVideo'))
    }

    if (backgroundImage && (typeof backgroundImage !== 'string' || !(backgroundImage.includes('file://') || backgroundImage.includes('data:')))) {
      return reject(new Error('backgroundImage: invalid param'))
    }

    if (backgroundVideo && (typeof backgroundVideo !== 'string' || !(backgroundVideo.includes('file://') || backgroundVideo.includes('data:')))) {
      return reject(new Error('backgroundVideo: invalid param'))
    }

    if (stickerImage && (typeof stickerImage !== 'string' || !(stickerImage.includes('file://') || stickerImage.includes('data:')))) {
      return reject(new Error('stickerImage: invalid param'))
    }

    if (backgroundTopColor && (typeof backgroundTopColor !== 'string' || !backgroundTopColor.includes('#'))) {
      return reject(new Error('backgroundTopColor: invalid param'))
    } 

    if (backgroundBottomColor && (typeof backgroundBottomColor !== 'string' || !backgroundBottomColor.includes('#'))) {
      return reject(new Error('backgroundBottomColor: invalid param'))
    } 

    if (contentURL && (typeof contentURL !== 'string' || !contentURL.includes('://'))) {
      return reject(new Error('contentURL: invalid param'))
    } 

    Linking.canOpenURL('instagram-stories://')
      .then(() => RNInstagramStoryShare.share({
        appId,
        provider,
        backgroundImage, 
        backgroundVideo, 
        stickerImage, 
        backgroundTopColor, 
        backgroundBottomColor, 
        contentURL,
      }))
      .then(() => resolve())
      .catch(error => reject(error))
  })
}

module.exports = {share}