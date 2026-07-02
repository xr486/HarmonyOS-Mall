@Component
export struct LazyImage {
  @Prop src: string = '';
  @Prop alt?: Resource;
  @Prop width?: string | number = '100%';
  @Prop height?: string | number = 160;
  @Prop objectFit?: ImageFit = ImageFit.Cover;
  @Prop borderRadius?: number | BorderRadius = 0;

  @State isLoaded: boolean = false;
  @State isVisible: boolean = false;
  @State errorOccurred: boolean = false;

  aboutToAppear(): void {
    this.checkVisibility();
  }

  checkVisibility(): void {
    setTimeout(() => {
      this.isVisible = true;
    }, 100);
  }

  onImageLoaded(): void {
    this.isLoaded = true;
  }

  onImageError(): void {
    this.errorOccurred = true;
    this.isLoaded = true;
  }

  build() {
    Column() {
      if (!this.isLoaded) {
        Column() {
          Progress({ value: 0, total: 100, type: ProgressType.Linear })
            .width('60%')
            .height(2)
            .color('#FF4D4F')
            .backgroundColor('#F0F0F0')
        }
        .width(this.width)
        .height(this.height)
        .backgroundColor('#F5F5F5')
        .justifyContent(FlexAlign.Center)
        .borderRadius(this.borderRadius)
      }

      if (this.isVisible) {
        Image(this.src)
          .width(this.width)
          .height(this.height)
          .objectFit(this.objectFit)
          .borderRadius(this.borderRadius)
          .alt(this.alt || $r('app.media.app_icon'))
          .onComplete(() => { this.onImageLoaded(); })
          .onError(() => { this.onImageError(); })
          .opacity(this.isLoaded ? 1 : 0)
          .transition({ type: TransitionType.Opacity, duration: 300 })
      }
    }
    .width(this.width)
    .height(this.height)
  }
}
