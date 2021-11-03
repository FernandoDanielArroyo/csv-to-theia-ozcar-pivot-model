const fs = require('fs')
const json = require('./pivot.json');

fs.writeFile('./pivot_corrected.json', JSON.stringify(addGeojsonProperties(clean(json))), err => {
    if (err) {
        console.error(err)
        return
    }
    //file written successfully
})

function clean(object) {
    Object
        .entries(object)
        .forEach(([k, v]) => {
            if (v && typeof v === 'object') {
                clean(v);
            }
            if (v && typeof v === 'object' && !Object.keys(v).length || v === null || v === undefined) {
                if (Array.isArray(object)) {
                    object.splice(k, 1);
                } else {
                    delete object[k];
                }
            }
        });
    return object;
}

function addGeojsonProperties(object) {
  
      Object
        .entries(object)
        .forEach(([k, v]) => {
            if (v && typeof v === 'object') {
                addGeojsonProperties(v);
            }
            if(k === "samplingFeature" || k === "spatialExtent") {
             object[k].properties = {}
            }
        });
        return object;
}