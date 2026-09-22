// Proyecto base: contiene oportunidades de mejora intencionales.
function calcularTotal(precio,cantidad){
  if(precio<0||cantidad<0)return 0;
  return precio*cantidad;
}

function resumenProducto(nombre,precio,cantidad){
  let total=precio*cantidad;
  return nombre+" | Cantidad: "+cantidad+" | Total: Q"+total;
}

function validarProducto(nombre,precio,cantidad){
  if(nombre==null || nombre=="") return false;
  if(precio<0) return false;
  if(cantidad<0) return false;
  return true;
}

module.exports={calcularTotal,resumenProducto,validarProducto};

if(require.main===module){
 console.log(resumenProducto("Teclado",150,2));
}