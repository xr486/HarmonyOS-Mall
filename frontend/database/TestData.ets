
import { Product, Category, ProductSpec } from '../common/models';

/**
 * 测试数据生成器
 */
export class TestData {
  /**
   * 生成分类数据
   */
  static generateCategories(): Category[] {
    const now = Date.now();
    return [
      {
        categoryId: 'cat_001',
        name: '手机数码',
        icon: 'https://example.com/icons/phone.png',
        parentId: '',
        sortOrder: 1,
        createdAt: now,
        updatedAt: now
      },
      {
        categoryId: 'cat_002',
        name: '电脑办公',
        icon: 'https://example.com/icons/computer.png',
        parentId: '',
        sortOrder: 2,
        createdAt: now,
        updatedAt: now
      },
      {
        categoryId: 'cat_003',
        name: '家用电器',
        icon: 'https://example.com/icons/appliance.png',
        parentId: '',
        sortOrder: 3,
        createdAt: now,
        updatedAt: now
      },
      {
        categoryId: 'cat_004',
        name: '服装鞋包',
        icon: 'https://example.com/icons/clothes.png',
        parentId: '',
        sortOrder: 4,
        createdAt: now,
        updatedAt: now
      },
      {
        categoryId: 'cat_005',
        name: '食品生鲜',
        icon: 'https://example.com/icons/food.png',
        parentId: '',
        sortOrder: 5,
        createdAt: now,
        updatedAt: now
      },
      {
        categoryId: 'cat_001_001',
        name: '手机',
        icon: '',
        parentId: 'cat_001',
        sortOrder: 1,
        createdAt: now,
        updatedAt: now
      },
      {
        categoryId: 'cat_001_002',
        name: '平板',
        icon: '',
        parentId: 'cat_001',
        sortOrder: 2,
        createdAt: now,
        updatedAt: now
      },
      {
        categoryId: 'cat_001_003',
        name: '智能手表',
        icon: '',
        parentId: 'cat_001',
        sortOrder: 3,
        createdAt: now,
        updatedAt: now
      },
      {
        categoryId: 'cat_002_001',
        name: '笔记本',
        icon: '',
        parentId: 'cat_002',
        sortOrder: 1,
        createdAt: now,
        updatedAt: now
      },
      {
        categoryId: 'cat_002_002',
        name: '台式机',
        icon: '',
        parentId: 'cat_002',
        sortOrder: 2,
        createdAt: now,
        updatedAt: now
      }
    ];
  }

  /**
   * 生成商品数据（20条+）
   */
  static generateProducts(): Product[] {
    const now = Date.now();
    const products: Product[] = [];

    // 手机数码类商品
    const phoneSpecs: ProductSpec[] = [
      { name: '颜色', values: ['黑色', '白色', '蓝色', '紫色'] },
      { name: '存储', values: ['128GB', '256GB', '512GB'] }
    ];

    products.push(
      {
        productId: 'prod_001',
        name: '华为 Mate 60 Pro',
        description: '全新一代华为旗舰手机，搭载麒麟9000S芯片',
        price: 699900,
        originalPrice: 799900,
        stock: 100,
        images: [
          'https://example.com/images/mate60_1.jpg',
          'https://example.com/images/mate60_2.jpg'
        ],
        brand: '华为',
        categoryId: 'cat_001_001',
        rating: 4.8,
        salesCount: 5000,
        specs: phoneSpecs,
        createdAt: now
      },
      {
        productId: 'prod_002',
        name: '华为 MatePad Pro',
        description: '华为旗舰平板，生产力工具',
        price: 499900,
        originalPrice: 549900,
        stock: 50,
        images: [
          'https://example.com/images/matepad_1.jpg',
          'https://example.com/images/matepad_2.jpg'
        ],
        brand: '华为',
        categoryId: 'cat_001_002',
        rating: 4.7,
        salesCount: 3000,
        specs: [
          { name: '颜色', values: ['曜石灰', '冰霜银'] },
          { name: '存储', values: ['128GB', '256GB'] }
        ],
        createdAt: now
      },
      {
        productId: 'prod_003',
        name: '华为 Watch GT 4',
        description: '华为智能手表，健康管理',
        price: 148800,
        originalPrice: 158800,
        stock: 200,
        images: [
          'https://example.com/images/watch_1.jpg',
          'https://example.com/images/watch_2.jpg'
        ],
        brand: '华为',
        categoryId: 'cat_001_003',
        rating: 4.6,
        salesCount: 8000,
        specs: [
          { name: '颜色', values: ['黑色', '绿色', '银色'] }
        ],
        createdAt: now
      },
      {
        productId: 'prod_004',
        name: 'iPhone 15 Pro Max',
        description: '苹果最新旗舰手机',
        price: 999900,
        originalPrice: 1099900,
        stock: 80,
        images: [
          'https://example.com/images/iphone15_1.jpg',
          'https://example.com/images/iphone15_2.jpg'
        ],
        brand: 'Apple',
        categoryId: 'cat_001_001',
        rating: 4.9,
        salesCount: 10000,
        specs: phoneSpecs,
        createdAt: now
      },
      {
        productId: 'prod_005',
        name: '小米 14 Ultra',
        description: '小米影像旗舰',
        price: 599900,
        originalPrice: 649900,
        stock: 150,
        images: [
          'https://example.com/images/mi14_1.jpg',
          'https://example.com/images/mi14_2.jpg'
        ],
        brand: '小米',
        categoryId: 'cat_001_001',
        rating: 4.7,
        salesCount: 6000,
        specs: phoneSpecs,
        createdAt: now
      },
      {
        productId: 'prod_006',
        name: 'OPPO Find X7 Ultra',
        description: 'OPPO影像旗舰，双潜望镜头',
        price: 599900,
        originalPrice: 629900,
        stock: 120,
        images: [
          'https://example.com/images/findx7_1.jpg',
          'https://example.com/images/findx7_2.jpg'
        ],
        brand: 'OPPO',
        categoryId: 'cat_001_001',
        rating: 4.6,
        salesCount: 4500,
        specs: phoneSpecs,
        createdAt: now
      },
      {
        productId: 'prod_007',
        name: 'vivo X100 Pro',
        description: 'vivo影像旗舰，蔡司光学',
        price: 499900,
        originalPrice: 529900,
        stock: 180,
        images: [
          'https://example.com/images/vivox100_1.jpg',
          'https://example.com/images/vivox100_2.jpg'
        ],
        brand: 'vivo',
        categoryId: 'cat_001_001',
        rating: 4.7,
        salesCount: 5500,
        specs: phoneSpecs,
        createdAt: now
      },
      {
        productId: 'prod_008',
        name: '荣耀 Magic 6 Pro',
        description: '荣耀影像旗舰',
        price: 569900,
        originalPrice: 619900,
        stock: 90,
        images: [
          'https://example.com/images/magic6_1.jpg',
          'https://example.com/images/magic6_2.jpg'
        ],
        brand: '荣耀',
        categoryId: 'cat_001_001',
        rating: 4.6,
        salesCount: 4000,
        specs: phoneSpecs,
        createdAt: now
      },
      {
        productId: 'prod_009',
        name: 'iPad Pro 12.9',
        description: '苹果专业平板',
        price: 899900,
        originalPrice: 949900,
        stock: 40,
        images: [
          'https://example.com/images/ipadpro_1.jpg',
          'https://example.com/images/ipadpro_2.jpg'
        ],
        brand: 'Apple',
        categoryId: 'cat_001_002',
        rating: 4.8,
        salesCount: 2500,
        specs: [
          { name: '存储', values: ['256GB', '512GB', '1TB'] }
        ],
        createdAt: now
      },
      {
        productId: 'prod_010',
        name: '三星 Galaxy S24 Ultra',
        description: '三星旗舰手机',
        price: 899900,
        originalPrice: 949900,
        stock: 70,
        images: [
          'https://example.com/images/s24_1.jpg',
          'https://example.com/images/s24_2.jpg'
        ],
        brand: 'Samsung',
        categoryId: 'cat_001_001',
        rating: 4.7,
        salesCount: 3500,
        specs: phoneSpecs,
        createdAt: now
      }
    );

    // 电脑办公类商品
    const laptopSpecs: ProductSpec[] = [
      { name: '颜色', values: ['银色', '深空灰'] },
      { name: '配置', values: ['i5/16G/512G', 'i7/16G/1TB', 'i9/32G/2TB'] }
    ];

    products.push(
      {
        productId: 'prod_011',
        name: '华为 MateBook X Pro',
        description: '华为旗舰轻薄本',
        price: 899900,
        originalPrice: 999900,
        stock: 60,
        images: [
          'https://example.com/images/matebook_1.jpg',
          'https://example.com/images/matebook_2.jpg'
        ],
        brand: '华为',
        categoryId: 'cat_002_001',
        rating: 4.7,
        salesCount: 2000,
        specs: laptopSpecs,
        createdAt: now
      },
      {
        productId: 'prod_012',
        name: 'MacBook Pro 14',
        description: '苹果专业笔记本',
        price: 1299900,
        originalPrice: 1399900,
        stock: 30,
        images: [
          'https://example.com/images/macbook_1.jpg',
          'https://example.com/images/macbook_2.jpg'
        ],
        brand: 'Apple',
        categoryId: 'cat_002_001',
        rating: 4.9,
        salesCount: 1800,
        specs: [
          { name: '配置', values: ['M3/16G/512G', 'M3 Pro/18G/1TB', 'M3 Max/32G/2TB'] }
        ],
        createdAt: now
      },
      {
        productId: 'prod_013',
        name: '联想 ThinkPad X1 Carbon',
        description: '商务旗舰本',
        price: 999900,
        originalPrice: 1099900,
        stock: 45,
        images: [
          'https://example.com/images/x1_1.jpg',
          'https://example.com/images/x1_2.jpg'
        ],
        brand: '联想',
        categoryId: 'cat_002_001',
        rating: 4.6,
        salesCount: 1500,
        specs: laptopSpecs,
        createdAt: now
      },
      {
        productId: 'prod_014',
        name: '戴尔 XPS 15',
        description: '戴尔旗舰本',
        price: 849900,
        originalPrice: 899900,
        stock: 55,
        images: [
          'https://example.com/images/xps_1.jpg',
          'https://example.com/images/xps_2.jpg'
        ],
        brand: 'Dell',
        categoryId: 'cat_002_001',
        rating: 4.5,
        salesCount: 1200,
        specs: laptopSpecs,
        createdAt: now
      },
      {
        productId: 'prod_015',
        name: '惠普 Spectre x360',
        description: '惠普翻转本',
        price: 799900,
        originalPrice: 849900,
        stock: 40,
        images: [
          'https://example.com/images/spectre_1.jpg',
          'https://example.com/images/spectre_2.jpg'
        ],
        brand: 'HP',
        categoryId: 'cat_002_001',
        rating: 4.5,
        salesCount: 1000,
        specs: laptopSpecs,
        createdAt: now
      },
      {
        productId: 'prod_016',
        name: '华硕 ROG 幻 16',
        description: '游戏本',
        price: 1099900,
        originalPrice: 1199900,
        stock: 35,
        images: [
          'https://example.com/images/rog_1.jpg',
          'https://example.com/images/rog_2.jpg'
        ],
        brand: '华硕',
        categoryId: 'cat_002_001',
        rating: 4.7,
        salesCount: 900,
        specs: [
          { name: '配置', values: ['i7/16G/1TB/4060', 'i9/32G/2TB/4080'] }
        ],
        createdAt: now
      }
    );

    // 家用电器类商品
    products.push(
      {
        productId: 'prod_017',
        name: '格力新一级能效空调',
        description: '格力智能空调',
        price: 399900,
        originalPrice: 459900,
        stock: 100,
        images: [
          'https://example.com/images/gree_1.jpg',
          'https://example.com/images/gree_2.jpg'
        ],
        brand: '格力',
        categoryId: 'cat_003',
        rating: 4.8,
        salesCount: 3000,
        specs: [
          { name: '匹数', values: ['1匹', '1.5匹', '2匹'] }
        ],
        createdAt: now
      },
      {
        productId: 'prod_018',
        name: '美的滚筒洗衣机',
        description: '美的智能洗衣机',
        price: 249900,
        originalPrice: 289900,
        stock: 150,
        images: [
          'https://example.com/images/midea_1.jpg',
          'https://example.com/images/midea_2.jpg'
        ],
        brand: '美的',
        categoryId: 'cat_003',
        rating: 4.6,
        salesCount: 2500,
        specs: [
          { name: '容量', values: ['10KG', '12KG'] }
        ],
        createdAt: now
      },
      {
        productId: 'prod_019',
        name: '海尔法式多门冰箱',
        description: '海尔智能冰箱',
        price: 599900,
        originalPrice: 659900,
        stock: 80,
        images: [
          'https://example.com/images/haier_1.jpg',
          'https://example.com/images/haier_2.jpg'
        ],
        brand: '海尔',
        categoryId: 'cat_003',
        rating: 4.7,
        salesCount: 1800,
        specs: [
          { name: '容量', values: ['400L', '500L', '600L'] }
        ],
        createdAt: now
      },
      {
        productId: 'prod_020',
        name: '小米扫地机器人',
        description: '小米智能扫地机器人',
        price: 199900,
        originalPrice: 249900,
        stock: 200,
        images: [
          'https://example.com/images/robot_1.jpg',
          'https://example.com/images/robot_2.jpg'
        ],
        brand: '小米',
        categoryId: 'cat_003',
        rating: 4.5,
        salesCount: 4000,
        specs: [],
        createdAt: now
      },
      {
        productId: 'prod_021',
        name: '戴森吸尘器',
        description: '戴森无线吸尘器',
        price: 399900,
        originalPrice: 449900,
        stock: 100,
        images: [
          'https://example.com/images/dyson_1.jpg',
          'https://example.com/images/dyson_2.jpg'
        ],
        brand: '戴森',
        categoryId: 'cat_003',
        rating: 4.8,
        salesCount: 2000,
        specs: [
          { name: '版本', values: ['V10', 'V11', 'V12'] }
        ],
        createdAt: now
      },
      {
        productId: 'prod_022',
        name: '索尼 75英寸电视',
        description: '索尼4K智能电视',
        price: 1099900,
        originalPrice: 1299900,
        stock: 40,
        images: [
          'https://example.com/images/sony_1.jpg',
          'https://example.com/images/sony_2.jpg'
        ],
        brand: 'Sony',
        categoryId: 'cat_003',
        rating: 4.9,
        salesCount: 800,
        specs: [
          { name: '尺寸', values: ['65英寸', '75英寸', '85英寸'] }
        ],
        createdAt: now
      },
      {
        productId: 'prod_023',
        name: '华为智慧屏 SE 65',
        description: '华为智能电视',
        price: 299900,
        originalPrice: 349900,
        stock: 120,
        images: [
          'https://example.com/images/se65_1.jpg',
          'https://example.com/images/se65_2.jpg'
        ],
        brand: '华为',
        categoryId: 'cat_003',
        rating: 4.6,
        salesCount: 1500,
        specs: [
          { name: '尺寸', values: ['55英寸', '65英寸', '75英寸'] }
        ],
        createdAt: now
      },
      {
        productId: 'prod_024',
        name: '美的电饭煲',
        description: '美的智能电饭煲',
        price: 49900,
        originalPrice: 59900,
        stock: 300,
        images: [
          'https://example.com/images/rice_1.jpg',
          'https://example.com/images/rice_2.jpg'
        ],
        brand: '美的',
        categoryId: 'cat_003',
        rating: 4.4,
        salesCount: 5000,
        specs: [
          { name: '容量', values: ['3L', '4L', '5L'] }
        ],
        createdAt: now
      }
    );

    return products;
  }
}
