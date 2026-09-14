// Exportación del listado mensual de facturas a CSV (REQ-003).
//
// La exportación es un ESPEJO: selecciona, ordena y serializa; no recalcula ningún
// importe (CA-06), no corrige incoherencias de la entrada (CA-07) y no altera los
// textos (CA-15). Devuelve la cadena CSV; no escribe en disco.
'use strict';

// --- Contrato de la salida ------------------------------------------------

// Sitio único de las columnas de la exportación (CA-01, CA-14). Orden y nombres
// son DE CONTRATO: cambiarlos exige ADR y write-back.
const COLUMNAS = Object.freeze(['id', 'fecha', 'cliente', 'descripcion', 'monto', 'comision', 'total']);

// Campos de importe, según la «Forma mínima de una factura» del REQ.
const CAMPOS_IMPORTE = Object.freeze(['monto', 'comision', 'total']);

const SEPARADOR = ',';
const DELIMITADOR = '"';
const FIN_DE_REGISTRO = '\r\n'; // CRLF, de contrato (RFC 4180, CA-02)
const DECIMALES_MINIMOS = 2; // de contrato (CA-08)

const FORMA_FECHA = /^\d{4}-\d{2}-\d{2}$/;
const NOTACION_EXPONENCIAL = /^(\d+)(?:\.(\d+))?e([+-]\d+)$/i;

// --- Utilidades de diagnóstico -------------------------------------------

/**
 * Describe un valor para un mensaje de error sin volcar su contenido cuando es
 * un objeto: los mensajes nombran la factura y el campo (CA-17/CA-18), no los
 * datos del cliente, que no tienen por qué acabar en un log.
 */
function describirValor(valor) {
  if (valor === null) return 'null';
  const tipo = typeof valor;
  if (tipo === 'number' || tipo === 'boolean' || tipo === 'undefined') return String(valor);
  return tipo;
}

/** Nombra la factura por su `id`; si el `id` falta, por su posición (CA-17). */
function describirFactura(factura, indice) {
  const id = factura.id;
  return typeof id === 'string' && id !== ''
    ? `la factura "${id}"`
    : `la factura en la posición ${indice}`;
}

// --- Formato de los valores ----------------------------------------------

function rellenar(numero, ancho) {
  return String(numero).padStart(ancho, '0');
}

/**
 * Texto `AAAA-MM-DD` de la fecha de emisión (CA-10).
 *
 * De un `Date` se toman los componentes UTC: es la única lectura que no depende
 * de la zona horaria del proceso, de modo que la misma entrada produce la misma
 * salida en cualquier máquina (CA-13) y ninguna conversión de zona desplaza el día.
 */
function textoDeFecha(valor, sujeto) {
  if (typeof valor === 'string') {
    if (!FORMA_FECHA.test(valor)) {
      throw new Error(`${sujeto}: el campo "fecha" no tiene la forma AAAA-MM-DD`);
    }
    return valor;
  }
  if (valor instanceof Date) {
    if (Number.isNaN(valor.getTime())) {
      throw new Error(`${sujeto}: el campo "fecha" es un Date inválido`);
    }
    const anio = valor.getUTCFullYear();
    if (anio < 0 || anio > 9999) {
      throw new Error(`${sujeto}: el campo "fecha" tiene un año que no cabe en AAAA-MM-DD`);
    }
    return `${rellenar(anio, 4)}-${rellenar(valor.getUTCMonth() + 1, 2)}-${rellenar(valor.getUTCDate(), 2)}`;
  }
  throw new Error(`${sujeto}: el campo "fecha" debe ser una cadena AAAA-MM-DD o un Date (recibido: ${describirValor(valor)})`);
}

/**
 * Representación decimal posicional de un número finito, sin exponente.
 *
 * Parte de `String(numero)`, que es la representación más corta que vuelve al
 * mismo valor, y sólo reubica el punto: así el texto emitido releído con
 * `Number` es `===` al valor de entrada (CA-08), sin truncar ni redondear.
 */
function aPosicional(numero) {
  let texto = String(numero);
  let signo = '';
  if (texto.startsWith('-')) {
    signo = '-';
    texto = texto.slice(1);
  }
  const exponencial = NOTACION_EXPONENCIAL.exec(texto);
  if (exponencial === null) return signo + texto;

  const [, entera, fraccionaria = '', exponente] = exponencial;
  const digitos = entera + fraccionaria;
  const punto = entera.length + Number(exponente);
  if (punto >= digitos.length) return signo + digitos + '0'.repeat(punto - digitos.length);
  if (punto <= 0) return `${signo}0.${'0'.repeat(-punto)}${digitos}`;
  return `${signo + digitos.slice(0, punto)}.${digitos.slice(punto)}`;
}

/** Rellena con ceros a la derecha hasta el mínimo de decimales (no altera el valor). */
function conDecimalesMinimos(texto) {
  const punto = texto.indexOf('.');
  if (punto === -1) return `${texto}.${'0'.repeat(DECIMALES_MINIMOS)}`;
  const decimales = texto.length - punto - 1;
  return decimales >= DECIMALES_MINIMOS ? texto : texto + '0'.repeat(DECIMALES_MINIMOS - decimales);
}

/** Celda de un importe (CA-08, CA-09); falla si no es un número finito (CA-18). */
function textoDeImporte(valor, sujeto, campo) {
  if (typeof valor !== 'number' || !Number.isFinite(valor)) {
    throw new Error(`${sujeto}: el campo "${campo}" debe ser un número finito (recibido: ${describirValor(valor)})`);
  }
  return conDecimalesMinimos(aPosicional(valor));
}

function textoObligatorio(valor, sujeto, campo, noVacia) {
  if (typeof valor !== 'string' || (noVacia && valor === '')) {
    throw new Error(`${sujeto}: el campo "${campo}" debe ser una cadena${noVacia ? ' no vacía' : ''} (recibido: ${describirValor(valor)})`);
  }
  return valor;
}

/** `descripcion` es el único campo opcional; ausente o vacío se emite como celda vacía (CA-16). */
function textoDeDescripcion(valor, sujeto) {
  if (valor === undefined || valor === null || valor === '') return '';
  if (typeof valor !== 'string') {
    throw new Error(`${sujeto}: el campo "descripcion" debe ser una cadena (recibido: ${describirValor(valor)})`);
  }
  return valor;
}

// --- Serialización CSV ----------------------------------------------------

/** Entrecomillado incondicional con la comilla interna duplicada (CA-03). */
function entrecomillar(texto) {
  return DELIMITADOR + texto.split(DELIMITADOR).join(DELIMITADOR + DELIMITADOR) + DELIMITADOR;
}

function construirLinea(celdas) {
  return celdas.map((celda) => entrecomillar(celda)).join(SEPARADOR);
}

// --- Orden ----------------------------------------------------------------

/** Comparación por punto de código Unicode (CA-13), no por unidad UTF-16. */
function compararPorPuntoDeCodigo(a, b) {
  const puntosA = Array.from(a);
  const puntosB = Array.from(b);
  const comunes = Math.min(puntosA.length, puntosB.length);
  for (let i = 0; i < comunes; i += 1) {
    const puntoA = puntosA[i].codePointAt(0);
    const puntoB = puntosB[i].codePointAt(0);
    if (puntoA !== puntoB) return puntoA < puntoB ? -1 : 1;
  }
  return puntosA.length - puntosB.length;
}

function compararFilas(a, b) {
  const porFecha = compararPorPuntoDeCodigo(a.fecha, b.fecha);
  if (porFecha !== 0) return porFecha;
  const porId = compararPorPuntoDeCodigo(a.id, b.id);
  if (porId !== 0) return porId;
  // Desempate final por la línea ya serializada: sin él, dos facturas con la
  // misma fecha y el mismo id saldrían en el orden de llegada y CA-13 exige
  // cadenas idénticas byte a byte para cualquier orden de llegada.
  return compararPorPuntoDeCodigo(a.linea, b.linea);
}

// --- Validación de los argumentos ----------------------------------------

function validarPeriodo(anio, mes) {
  if (!Number.isInteger(anio)) {
    throw new Error(`el argumento "anio" debe ser un entero (recibido: ${describirValor(anio)})`);
  }
  if (!Number.isInteger(mes) || mes < 1 || mes > 12) {
    throw new Error(`el argumento "mes" debe ser un entero entre 1 y 12 (recibido: ${describirValor(mes)})`);
  }
}

// --- Punto de entrada -----------------------------------------------------

/**
 * Construye la fila de una factura seleccionada, validando sus campos.
 * Sólo se emiten las columnas del sitio único CA-01: cualquier propiedad
 * adicional del objeto de entrada se ignora (CA-14).
 */
function construirFila(factura, sujeto, fecha) {
  const valores = {
    id: textoObligatorio(factura.id, sujeto, 'id', true),
    fecha,
    cliente: textoObligatorio(factura.cliente, sujeto, 'cliente', false),
    descripcion: textoDeDescripcion(factura.descripcion, sujeto),
  };
  for (const campo of CAMPOS_IMPORTE) {
    valores[campo] = textoDeImporte(factura[campo], sujeto, campo);
  }
  return {
    fecha,
    id: valores.id,
    linea: construirLinea(COLUMNAS.map((columna) => valores[columna])),
  };
}

/**
 * Exporta a CSV (RFC 4180) las facturas del año y mes indicados.
 *
 * @param {Array<object>} facturas listado de facturas (de cualquier mes)
 * @param {number} anio año entero
 * @param {number} mes mes entero entre 1 y 12
 * @returns {string} cadena CSV con el encabezado y una línea por factura del mes
 * @throws {Error} si los argumentos o alguna factura exportable no cumplen la
 *   forma contratada en REQ-003; en ese caso no se devuelve ninguna salida.
 */
function exportarFacturasACsv(facturas, anio, mes) {
  if (!Array.isArray(facturas)) {
    throw new Error(`el argumento "facturas" debe ser un arreglo (recibido: ${describirValor(facturas)})`);
  }
  validarPeriodo(anio, mes);

  const filas = [];
  for (let indice = 0; indice < facturas.length; indice += 1) {
    const factura = facturas[indice];
    if (factura === null || typeof factura !== 'object') {
      throw new Error(`la factura en la posición ${indice} no es un objeto de factura (recibido: ${describirValor(factura)})`);
    }
    const sujeto = describirFactura(factura, indice);
    // La fecha se comprueba en todas las facturas porque sin ella no se puede
    // decidir a qué mes pertenecen; las de otro mes se excluyen en silencio (CA-11).
    const fecha = textoDeFecha(factura.fecha, sujeto);
    if (Number(fecha.slice(0, 4)) !== anio || Number(fecha.slice(5, 7)) !== mes) continue;
    filas.push(construirFila(factura, sujeto, fecha));
  }

  filas.sort(compararFilas);

  const lineas = [construirLinea(COLUMNAS)];
  for (const fila of filas) lineas.push(fila.linea);
  return lineas.map((linea) => linea + FIN_DE_REGISTRO).join('');
}

module.exports = { exportarFacturasACsv };
