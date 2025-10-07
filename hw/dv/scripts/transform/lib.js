'use strict';

let dvJson = null;

function initialize(json) {
  dvJson = json;
}

function isSingleDie() {
  return (dvJson.links && dvJson.links.length === 0);
}

function getAllChipletRefs() {
    const json = (typeof dvJson === 'string') ? JSON.parse(dvJson) : dvJson;
  
    const chiplets = Array.isArray(json?.chiplets) ? json.chiplets : [];
    const refMap   = (json && typeof json.chipletRef === 'object') ? json.chipletRef : {};
  
    const firstRef = Object.values(refMap)[0];
  
    // Edge single-die / no-chiplets case
    if (chiplets.length === 0) {
      const r = extractRoot(firstRef);
      return r ? [r] : [];
    }
  
    return chiplets
      .map(ch => {
        const key = ch?.master_chiplet ?? ch?.chiplet_name;
        let ref = (key in refMap) ? refMap[key] : undefined;
  
        // case-insensitive fallback
        if (ref === undefined && key) {
          const altKey = Object.keys(refMap).find(k => k.toLowerCase() === String(key).toLowerCase());
          if (altKey) ref = refMap[altKey];
        }
  
        if (ref === undefined) ref = firstRef; // final fallback to preserve length
  
        return extractRoot(ref);
      })
      .filter(Boolean);
  
    // Prefer ...chipletRef._root_; then ..._root_; then ...chipletRef; then the ref itself
    function extractRoot(ref) {
      return ref?.chipletRef?._root_ ?? ref?._root_ ?? ref?.chipletRef ?? ref ?? null;
    }
}  

function getAllChipletInstanceNames() {
    const json = (typeof dvJson === 'string') ? JSON.parse(dvJson) : dvJson;
  
    // Single-die: return the project/assembly name as a single-element array
    if (isSingleDie()) {
      const name = json?.assembly_name ?? json?.chiplets?.[0]?.chiplet_name;
      return name ? [name] : [];
    }
  
    // Multi-die: return instance names from the chiplets array
    const chiplets = Array.isArray(json?.chiplets) ? json.chiplets : [];
    return chiplets.map(c => c?.chiplet_name).filter(Boolean);
}

// common function to generate prefix either for single die or multi die
function getFullInstanceName(chiplet, unit, separator = '_') {
  const unitPrefix = typeof unit === 'string' ? unit : unit.strRtlNamePrefix || '';
  if (chiplet && !isSingleDie()) {
    return chiplet.chiplet_name + separator + unitPrefix;
  }
  return unitPrefix;
}
  

function getAllChipletModuleNames() {
  if (!isSingleDie())
    return Object.keys(dvJson.chipletRef);
  else
    return [];
}

module.exports = {
  initialize,
  isSingleDie,
  getAllChipletRefs,
  getAllChipletInstanceNames,
  getAllChipletModuleNames,
  getFullInstanceName
};