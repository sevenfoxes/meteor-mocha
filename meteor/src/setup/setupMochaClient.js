import {meteorInstall} from "meteor/modules"

// For some reason meteor-node-stubs is not working, TODO create an issue.
// Here we are creating stubs packages to be availabe on the client side. This must be called before mocha require
// See an example from https://goo.gl/us9YVR

export default ()=>{
  process.browser = true;

  meteorInstall({
    node_modules: {
      "tty.js": function (r, e, module) {
        module.exports = { isatty: ()=>{ return false}}
      }
    }
  });


  meteorInstall({
    node_modules: {
      "fs.js": function (r, e, module) {
        module.exports = {
          existsSync: ()=>{},
          readdirSync: ()=>{},
          statSync: ()=>{},
          watchFile: ()=>{}
        }
      }
    }
  });


  meteorInstall({
    node_modules: {
      "constants.js": function (r, e, module) {
        module.exports = {
          test: {'test':'test'}
        }
      }
    }
  });


}
