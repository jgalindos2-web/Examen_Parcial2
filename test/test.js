const assert=require("assert");
const {calcularTotal,validarProducto}=require("../src/app");
assert.strictEqual(calcularTotal(100,2),200);
assert.strictEqual(calcularTotal(-1,2),0);
assert.strictEqual(validarProducto("Mouse",75,3),true);
console.log("Pruebas iniciales OK");