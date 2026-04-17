const fs = require('fs');
const path = require('path');

const srcDir = path.join(process.argv[2], 'src');

function walk(dir) {
    let results = [];
    const list = fs.readdirSync(dir);
    list.forEach(file => {
        const filePath = path.join(dir, file);
        const stat = fs.statSync(filePath);
        if (stat && stat.isDirectory()) {
            results = results.concat(walk(filePath));
        } else {
            results.push(filePath);
        }
    });
    return results;
}

const allFiles = walk(srcDir);
const filesToRename = [];

allFiles.forEach(file => {
    if (file.endsWith('.js') || file.endsWith('.jsx')) {
        let content = fs.readFileSync(file, 'utf8');
        // Replace something like `HomeScreen` with `Home`
        let newContent = content.replace(/([A-Za-z0-9]+)Screen/g, '$1');
        // Edge cases for imports if needed, but the regex above matches them.
        if (content !== newContent) {
            fs.writeFileSync(file, newContent, 'utf8');
            console.log('Updated contents of', file);
        }
    }

    const basename = path.basename(file);
    if (basename.includes('Screen')) {
        const newBasename = basename.replace('Screen', '');
        const newPath = path.join(path.dirname(file), newBasename);
        filesToRename.push({ oldPath: file, newPath: newPath });
    }
});

filesToRename.forEach(item => {
    fs.renameSync(item.oldPath, item.newPath);
    console.log(`Renamed ${path.basename(item.oldPath)} to ${path.basename(item.newPath)}`);
});
