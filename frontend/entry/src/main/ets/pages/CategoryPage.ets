import { CategoryService } from '../services/product/CategoryService';
import { Category } from '../common/models';
import { router } from '@ohos.router';

@Entry
@Component
struct CategoryPage {
  @State categories: Category[] = [];
  @State selectedCategory: Category | null = null;
  @State childCategories: Category[] = [];
  @State isLoading: boolean = true;

  aboutToAppear(): void {
    this.loadCategories();
  }

  async loadCategories(): Promise<void> {
    this.isLoading = true;
    try {
      const service: CategoryService = CategoryService.getInstance();
      const allCategories: Category[] = await service.getAllCategories();
      this.categories = allCategories.filter((c: Category) => !c.parentId);
      if (this.categories.length > 0) {
        this.selectedCategory = this.categories[0];
        this.loadChildCategories(this.categories[0].categoryId);
      }
    } catch (e) {
      this.categories = [];
    }
    this.isLoading = false;
  }

  async loadChildCategories(parentId: string): Promise<void> {
    try {
      const service: CategoryService = CategoryService.getInstance();
      this.childCategories = await service.getChildCategories(parentId);
    } catch (e) {
      this.childCategories = [];
    }
  }

  onCategoryClick(category: Category): void {
    this.selectedCategory = category;
    this.loadChildCategories(category.categoryId);
  }

  onChildCategoryClick(category: Category): void {
    router.pushUrl({
      url: 'pages/ProductListPage',
      params: { categoryId: category.categoryId, categoryName: category.name }
    });
  }

  build() {
    Column() {
      Row() {
        Text('←')
          .fontSize(22)
          .onClick(() => { router.back(); })
        Text('商品分类')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Text('')
          .width(36)
      }
      .width('100%')
      .height(48)
      .padding({ left: 12, right: 12 })
      .backgroundColor(Color.White)

      if (this.isLoading) {
        Column() {
          LoadingProgress().width(40).height(40)
          Text('加载中...').fontSize(14).fontColor('#999').margin({ top: 8 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Row() {
          Scroll() {
            Column() {
              ForEach(this.categories, (cat: Category) => {
                Column() {
                  Row({ space: 8 }) {
                    if (cat.icon) {
                      Image(cat.icon)
                        .width(20)
                        .height(20)
                        .objectFit(ImageFit.Contain)
                    }
                    Text(cat.name)
                      .fontSize(14)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.selectedCategory?.categoryId === cat.categoryId ? '#FF4D4F' : '#333')
                  }
                  .width('100%')
                  .padding({ left: 16, right: 16, top: 16, bottom: 16 })
                  .justifyContent(FlexAlign.Start)

                  if (this.selectedCategory?.categoryId === cat.categoryId) {
                    Line()
                      .width(4)
                      .height('100%')
                      .backgroundColor('#FF4D4F')
                      .position({ left: 0, top: 0 })
                  }
                }
                .width('100%')
                .backgroundColor(this.selectedCategory?.categoryId === cat.categoryId ? '#FFF1F0' : '#FFFFFF')
                .onClick(() => { this.onCategoryClick(cat); })
              }, (cat: Category) => cat.categoryId)
            }
            .width('100%')
          }
          .width(120)
          .backgroundColor('#F5F5F5')

          Scroll() {
            Column() {
              if (this.childCategories.length > 0) {
                Column() {
                  ForEach(this.childCategories, (child: Category) => {
                    Column() {
                      if (child.icon) {
                        Image(child.icon)
                          .width(50)
                          .height(50)
                          .objectFit(ImageFit.Contain)
                          .margin({ bottom: 8 })
                      } else {
                        Column() {
                          Text(child.name.charAt(0))
                            .fontSize(24)
                            .fontWeight(FontWeight.Bold)
                            .fontColor('#FF4D4F')
                        }
                        .width(50)
                        .height(50)
                        .backgroundColor('#FFF1F0')
                        .borderRadius(25)
                        .justifyContent(FlexAlign.Center)
                        .alignItems(HorizontalAlign.Center)
                        .margin({ bottom: 8 })
                      }
                      Text(child.name)
                        .fontSize(12)
                        .fontColor('#333')
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                    }
                    .width('31%')
                    .padding({ top: 16, bottom: 16 })
                    .justifyContent(FlexAlign.Center)
                    .alignItems(HorizontalAlign.Center)
                    .backgroundColor(Color.White)
                    .borderRadius(8)
                    .onClick(() => { this.onChildCategoryClick(child); })
                  }, (child: Category) => child.categoryId)
                }
                .flexWrap(FlexWrap.Wrap)
                .justifyContent(FlexAlign.SpaceBetween)
                .padding(16)
                .width('100%')
              } else {
                Column() {
                  Text('暂无子分类')
                    .fontSize(14)
                    .fontColor('#999')
                }
                .width('100%')
                .padding(40)
                .justifyContent(FlexAlign.Center)
              }
            }
            .width('100%')
          }
          .layoutWeight(1)
          .backgroundColor('#FFFFFF')
        }
        .layoutWeight(1)
        .width('100%')
      }
    }
    .width('100%')
    .height('100%')
  }
}
