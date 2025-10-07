function parseXML(xmlString) {
    let parsing = true;
    let root = null;
    let currentElement = null;
    let stack = [];
  
    function processChunk(data) {
      let startIndex = 0;
  
      while (startIndex < data.length) {
        if (data[startIndex] === '<') {
          if (data[startIndex + 1] === '/') {
            // Closing tag
            let endIndex = data.indexOf('>', startIndex);
            if (endIndex === -1) {
              throw new Error('Malformed XML: unclosed tag');
            }
            let tagName = data.slice(startIndex + 2, endIndex).trim();
            if (currentElement && currentElement.name === tagName) {
              if (stack.length > 0) {
                currentElement = stack.pop();
              } else {
                parsing = false;
              }
            }
            startIndex = endIndex + 1;
          } else if (data[startIndex + 1] === '?') {
            // XML declaration or processing instruction
            let endIndex = data.indexOf('?>', startIndex);
            if (endIndex === -1) {
              throw new Error('Malformed XML: unclosed processing instruction');
            }
            startIndex = endIndex + 2;
          } else if (data.startsWith('<!--', startIndex)) {
            // Comment
            let endIndex = data.indexOf('-->', startIndex);
            if (endIndex === -1) {
              throw new Error('Malformed XML: unclosed comment');
            }
            startIndex = endIndex + 3;
          } else {
            // Opening tag
            let endIndex = data.indexOf('>', startIndex);
            if (endIndex === -1) {
              throw new Error('Malformed XML: unclosed tag');
            }
            let tag = data.slice(startIndex + 1, endIndex);
            let [tagName, ...attrParts] = tag.split(/\s+/);
            let attributes = {};
            attrParts.forEach(part => {
              let [key, value] = part.split('=');
              if (key && value) {
                attributes[key] = value.replace(/['"]/g, '');
              }
            });
            let newElement = { name: tagName, attributes, children: [] };
            if (!root) {
              root = newElement;
            } else {
              currentElement.children.push(newElement);
            }
            if (!tag.endsWith('/')) {
              if (currentElement) {
                stack.push(currentElement);
              }
              currentElement = newElement;
            }
            startIndex = endIndex + 1;
          }
        } else {
          // Text content
          let endIndex = data.indexOf('<', startIndex);
          if (endIndex === -1) {
            if (currentElement) {
              currentElement.text = (currentElement.text || '') + data.slice(startIndex).trim();
            }
            break;
          }
          if (currentElement) {
            currentElement.text = (currentElement.text || '') + data.slice(startIndex, endIndex).trim();
          }
          startIndex = endIndex;
        }
      }
    }
  
    xmlString = xmlString.replace(/^\uFEFF/, '');
  
    processChunk(xmlString);
  
    if (parsing) {
      throw new Error('Malformed XML: unexpected end of input');
    }
  
    return root;
  }
  
  module.exports = parseXML;