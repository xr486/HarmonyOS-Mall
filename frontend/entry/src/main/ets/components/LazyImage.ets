@Component
export struct LazyImage {
  @Prop src: string = '';
  @Prop alt: Resource = $r('app.media.app_icon');
  @Prop imgWidth: string | number = '100%';
  @Prop imgHeight: string | number = 160;
  @Prop objectFit: ImageFit = ImageFit.Cover;
  @Prop imgBorderRadius: number = 0;

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
        .width(this.imgWidth)
        .height(this.imgHeight)
        .backgroundColor('#F5F5F5')
        .justifyContent(FlexAlign.Center)
        .borderRadius(this.imgBorderRadius)
      }

      if (this.isVisible) {
        Image(this.src)
          .width(this.imgWidth)
          .height(this.imgHeight)
          .objectFit(this.objectFit)
          .borderRadius(this.imgBorderRadius)
          .alt(this.alt)
          .onComplete(() => { this.onImageLoaded(); })
          .onError(() => { this.onImageError(); })
          .opacity(this.isLoaded ? 1 : 0)
      }
    }
    .width(this.imgWidth)
    .height(this.imgHeight)
  }
}
