Pod::Spec.new do |s|
  s.name          = 'QQKit'
  s.version       = '1.0.0'
  s.summary       = '常用的UI组件'
  s.homepage      = 'https://github.com/MidPush/QQKit'
  s.license       = 'MIT'
  s.author        = { 'xz' => '497569855@qq.com' }
  s.platform      = :ios, '9.0'
  s.source        = { :git => 'https://github.com/MidPush/QQKit.git', :tag => s.version }
  s.requires_arc  = true
  s.source_files  = 'QQKit/QQKit.h'

  s.subspec 'QQCore' do |ss|
    ss.source_files = 'QQKit/QQCore/*.{h,m}'
    ss.resources = 'QQKit/QQCore/QQUIKit.bundle'
    ss.dependency 'QQKit/QQExtensions/UIDevice+QQExtension.{h.m}'
  end

  s.subspec 'QQComponents' do |ss|

    ss.subspec 'QQAssetPicker' do |sss|

      sss.subspec 'AssetLibrary' do |ssss|
        ssss.source_files = 'QQKit/QQComponents/QQAssetPicker/AssetLibrary/*.{h,m}'
        ssss.dependency 'QQKit/QQExtensions/NSObject+QQExtension.{h,m}'
        ssss.dependency 'QQKit/QQExtensions/UIImage+QQExtension.{h,m}'
        ssss.dependency 'QQKit/QQComponents/QQAssetPicker/ImageEdit/Constants/QQCropViewConstants.h'
      end

      sss.subspec 'Picker' do |ssss|
        ssss.source_files = 'QQKit/QQComponents/QQAssetPicker/Picker/*.{h,m}'
        ssss.dependency 'QQKit/QQExtensions/UIView+QQExtension.{h,m}'
        ssss.dependency 'QQKit/QQCore'
        ssss.dependency 'QQKit/QQComponents/QQAssetPicker/AssetLibrary'
        ssss.dependency 'QQKit/QQComponents/QQAssetPicker/Views'
        ssss.dependency 'QQKit/QQComponents/QQToast'
      end
      
      sss.subspec 'ImageEdit' do |ssss|
        ssss.source_files = 'QQKit/QQComponents/QQAssetPicker/ImageEdit/**/*.{h,m}'
        ssss.dependency 'QQKit/QQExtensions/UIView+QQExtension.{h,m}'
        ssss.dependency 'QQKit/QQCore'
        ssss.dependency 'QQKit/QQComponents/QQAssetPicker/AssetLibrary'
      end

      sss.subspec 'VideoEdit' do |ssss|
        ssss.source_files = 'QQKit/QQComponents/QQAssetPicker/VideoEdit/**/*.{h,m}'
        ssss.dependency 'QQKit/QQExtensions/UIView+QQExtension.{h,m}'
        ssss.dependency 'QQKit/QQCore'
        ssss.dependency 'QQKit/QQComponents/QQAssetPicker/AssetLibrary'
        ssss.dependency 'QQKit/QQComponents/QQToast'
      end

      sss.subspec 'Views' do |ssss|
        ssss.source_files = 'QQKit/QQComponents/QQAssetPicker/Views/*.{h,m}'
        ssss.dependency 'QQKit/QQExtensions/UIView+QQExtension.{h,m}'
        ssss.dependency 'QQKit/QQCore'
        ssss.dependency 'QQKit/QQComponents/QQAssetPicker/AssetLibrary'
      end

    end

    ss.subspec 'QQBadge' do |sss|
      sss.source_files = 'QQKit/QQComponents/QQBadge/*.{h,m}'
      sss.dependency 'QQKit/QQExtensions/UIView+QQExtension.{h,m}'
    end

    ss.subspec 'QQCircularProgress' do |sss|
      sss.source_files = 'QQKit/QQComponents/QQCircularProgress/*.{h,m}'
    end

    ss.subspec 'QQFakeNavigationBar' do |sss|
      sss.source_files = 'QQKit/QQComponents/QQFakeNavigationBar/*.{h,m}'
      sss.dependency 'QQKit/QQExtensions/UINavigationBar+QQExtension.{h,m}'
      sss.dependency 'QQKit/QQExtensions/UIImage+QQExtension.{h,m}'
      sss.dependency 'QQKit/QQCore/QQRuntime.h'
    end

    ss.subspec 'QQPageViewController' do |sss|
      sss.source_files = 'QQKit/QQComponents/QQPageViewController/*.{h,m}'
      sss.dependency 'QQKit/QQExtensions/UIView+QQExtension.{h,m}'
    end

    ss.subspec 'QQToast' do |sss|
      sss.source_files = 'QQKit/QQComponents/QQToast/*.{h,m}'
      sss.resources = 'QQKit/QQCore/QQUIKit.bundle'
    end

  end

  s.subspec 'QQControllers' do |ss|
    ss.source_files = 'QQKit/QQControllers/*.{h,m}'
    ss.dependency 'QQKit/QQCore'
  end

  s.subspec 'QQExtensions' do |ss|
    ss.source_files = 'QQKit/QQExtensions/*.{h,m}'
    ss.dependency 'QQKit/QQCore'
  end

  s.subspec 'QQTheme' do |ss|
    ss.source_files = 'QQKit/QQTheme/*.{h,m}'
  end

  s.subspec 'QQViews' do |ss|
    ss.source_files = 'QQKit/QQViews/**/*.{h,m}'
    ss.dependency 'QQKit/QQCore'
  end

end
