(exports ? this).globalize = (fxn)=>
  (exports ? this)[fxn.name] = fxn


# MOCKING #
(exports ? this).mocks = {}

(exports ? this).addMock = (name, obj)=>
  (exports ? this).mocks[name] = obj


# RUNTIME PATCHING #
(exports ? this).patches = {}

(exports ? this).patch = (method, patch)=>
  (exports ? this).patches[method.name] = method
  method = patch

(exports ? this).restore = (method)=>
  method = (exports ? this).patches[method.name]
  delete (exports ? this).patches[method.name]