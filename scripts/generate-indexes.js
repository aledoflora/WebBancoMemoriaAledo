const fs = require('fs');
const path = require('path');

const recetarioPath = path.join(__dirname, '..', 'data', 'recetario');

function isImage(name) {
  return /\.(jpe?g|png|gif|bmp|webp)$/i.test(name);
}

function isPDF(name) {
  return /\.pdf$/i.test(name);
}

function generate() {
  const folders = fs.readdirSync(recetarioPath, { withFileTypes: true })
    .filter(d => d.isDirectory())
    .map(d => d.name);

  folders.forEach(folder => {
    const folderPath = path.join(recetarioPath, folder);
    let files = [];

    try {
      files = fs.readdirSync(folderPath);
    } catch (err) {
      console.warn('No se puede leer', folderPath, err.message);
      return;
    }

    // Orden estable: imágenes primero, pdfs after, then others
    const images = files.filter(isImage);
    const pdfs = files.filter(isPDF);
    const others = files.filter(f => !isImage(f) && !isPDF(f));

    const index = {
      folder: folder,
      files: files.sort(),
      cover: images.length ? images[0] : null,
      pdf: pdfs.length ? pdfs[0] : null,
      generatedAt: new Date().toISOString()
    };

    const outPath = path.join(folderPath, 'index.json');
    fs.writeFileSync(outPath, JSON.stringify(index, null, 2), 'utf8');
    console.log('Wrote', outPath, 'cover=', index.cover, 'pdf=', index.pdf);
  });
}

generate();
