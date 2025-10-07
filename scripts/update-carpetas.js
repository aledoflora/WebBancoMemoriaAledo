const fs = require('fs');
const path = require('path');

// Ruta al directorio del recetario
const recetarioPath = path.join(__dirname, '..', 'data', 'recetario');

// Función para actualizar el JSON de carpetas
function updateCarpetasJSON() {
  try {
    // Leer el contenido del directorio
    const items = fs.readdirSync(recetarioPath, { withFileTypes: true });
    
    // Filtrar solo las carpetas (excluyendo archivos)
    const carpetas = items
      .filter(item => item.isDirectory())
      .map(item => item.name)
      .sort(); // Ordenar alfabéticamente
    
    // Crear el objeto JSON
    const jsonData = {
      carpetas: carpetas,
      notas: "Este archivo se actualiza automáticamente. No editar manualmente.",
      ultimaActualizacion: new Date().toISOString()
    };
    
    // Escribir el archivo JSON
    const jsonPath = path.join(recetarioPath, 'carpetas.json');
    fs.writeFileSync(jsonPath, JSON.stringify(jsonData, null, 2), 'utf8');
    
    console.log('✅ JSON actualizado exitosamente');
    console.log(`📁 Carpetas detectadas: ${carpetas.length}`);
    console.log(`📝 Carpetas: ${carpetas.join(', ')}`);
    
  } catch (error) {
    console.error('❌ Error al actualizar el JSON:', error.message);
  }
}

// Ejecutar la función
updateCarpetasJSON();

// Si se ejecuta con --watch, observar cambios en el directorio
if (process.argv.includes('--watch')) {
  console.log('👀 Observando cambios en el directorio...');
  fs.watch(recetarioPath, { recursive: true }, (eventType, filename) => {
    if (filename && !filename.endsWith('.json')) {
      console.log(`🔄 Cambio detectado: ${filename}`);
      setTimeout(updateCarpetasJSON, 100); // Pequeño delay para evitar múltiples actualizaciones
    }
  });
}
