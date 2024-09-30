// const wasmModuleUrl = "./target/wasm-gc/debug/build/lib/lib.wasm";
// const wasmModuleUrl = "./target/wasm-gc/release/build/lib/lib.wasm";

// import wasmModuleUrl from "./target/wasm-gc/debug/build/lib/lib.wasm?url";

// async function loadWasmModule(url) {
//   try {
//     const response = await fetch(url);
//     const bytes = await response.arrayBuffer();
//     const results = await WebAssembly.instantiate(bytes, {
//       basic: {
//         jslog_1: (x) => console.log(x),
//       },
//     });

//     const { onload } = results.instance.exports;
//     onload();
//   } catch (err) {
//     console.error("Error instantiating WebAssembly module:", err);
//   }
// }

// // Call the function with the URL of the Wasm module
// loadWasmModule(wasmModuleUrl);

impor;
