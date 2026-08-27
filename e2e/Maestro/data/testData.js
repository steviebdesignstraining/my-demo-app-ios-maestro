// Central test data + expected cart calculations.
// Maestro exposes this through the `output` object.
const products = {
  backpackRed: {
    name: 'Sauce Labs Backpack - Red',
    detail: 'Sauce Labs Backpack - Red',
    price: 29.99,
    productImageIndex: 3
  },
  boltBlack: {
    name: 'Sauce Labs Bolt T-Shirt - Black',
    detail: 'Sauce Labs Bolt T-Shirt - Black',
    price: 15.99,
    productImageIndex: 5
  },
  backpackOrange: {
    name: 'Sauce Labs Backpack - Orange',
    detail: 'Sauce Labs Backpack - Orange',
    price: 29.99,
    productImageIndex: 2
  }
};

function money(value) {
  return Number(value.toFixed(2));
}

function cartTotal(items) {
  return money(items.reduce((total, item) => {
    return total + (item.product.price * item.quantity);
  }, 0));
}

function cartItemCount(items) {
  return items.reduce((total, item) => total + item.quantity, 0);
}

const scenarios = {
  single: [
    { product: products.backpackRed, quantity: 1 }
  ],
  multiple: [
    { product: products.backpackRed, quantity: 1 },
    { product: products.boltBlack, quantity: 3 }
  ],
  removeOneProduct: [
    { product: products.backpackRed, quantity: 1 },
    { product: products.boltBlack, quantity: 1 },
    { product: products.backpackOrange, quantity: 3 }
  ],
  updateQuantity: [
    { product: products.backpackRed, quantity: 1 },
    { product: products.boltBlack, quantity: 1 },
    { product: products.backpackOrange, quantity: 6 }
  ]
};

output.testData = {
  products,
  scenarios,
  shipping: 5.99,
  expected: {
    singleTotal: cartTotal(scenarios.single),
    multipleTotal: cartTotal(scenarios.multiple),
    removeOneTotal: cartTotal(scenarios.removeOneProduct),
    removeOneItemCount: cartItemCount(scenarios.removeOneProduct),
    removeOneAfterTotal: cartTotal([
      { product: products.boltBlack, quantity: 1 },
      { product: products.backpackOrange, quantity: 3 }
    ]),
    removeOneAfterItemCount: 4,
    updateQuantityTotal: cartTotal(scenarios.updateQuantity),
    updateQuantityItemCount: cartItemCount(scenarios.updateQuantity),
    checkoutSubtotal: cartTotal(scenarios.multiple),
    checkoutTotal: money(cartTotal(scenarios.multiple) + 5.99)
  }
};

console.log('Calculated expected totals: ' + JSON.stringify(output.testData.expected));
