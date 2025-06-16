require("firecast.lua");
local __o_rrpgObjs = require("rrpgObjs.lua");
require("rrpgGUI.lua");
require("rrpgDialogs.lua");
require("rrpgLFM.lua");
require("ndb.lua");
require("locale.lua");
local __o_Utils = require("utils.lua");

local function constructNew_frmExportadorDePastas()
    local obj = GUI.fromHandle(_obj_newObject("form"));
    local self = obj;
    local sheet = nil;

    rawset(obj, "_oldSetNodeObjectFunction", obj.setNodeObject);

    function obj:setNodeObject(nodeObject)
        sheet = nodeObject;
        self.sheet = nodeObject;
        self:_oldSetNodeObjectFunction(nodeObject);
    end;

    function obj:setNodeDatabase(nodeObject)
        self:setNodeObject(nodeObject);
    end;

    _gui_assignInitialParentForForm(obj.handle);
    obj:beginUpdate();
    obj:setFormType("tablesDock");
    obj:setDataType("com.tkplayer.extractor");
    obj:setName("frmExportadorDePastas");
    obj:setTitle("Exportador de Pastas");
    obj:setWidth(300);
    obj:setHeight(120);


        exportador_logic = require("exporter.lua");
    


    obj.layout1 = GUI.fromHandle(_obj_newObject("layout"));
    obj.layout1:setParent(obj);
    obj.layout1:setAlign("client");
    obj.layout1:setMargins({top=10, bottom=10, left=10, right=10});
    obj.layout1:setName("layout1");

    obj.label1 = GUI.fromHandle(_obj_newObject("label"));
    obj.label1:setParent(obj.layout1);
    obj.label1:setAlign("top");
    obj.label1:setText("Este plugin exporta o conteúdo de todos os arquivos de uma pasta do seu FireDrive para um único arquivo .txt.");
    obj.label1:setAutoSize(true);
    obj.label1:setWordWrap(true);
    obj.label1:setName("label1");

    obj.button1 = GUI.fromHandle(_obj_newObject("button"));
    obj.button1:setParent(obj.layout1);
    obj.button1:setAlign("bottom");
    obj.button1:setText("Selecionar Pasta e Exportar");
    obj.button1:setHeight(40);
    obj.button1:setName("button1");

    obj._e_event0 = obj.button1:addEventListener("onClick",
        function (event)
            exportador_logic.iniciarExportacao(Firecast.getMesaDe(sheet))
        end);

    function obj:_releaseEvents()
        __o_rrpgObjs.removeEventListenerById(self._e_event0);
    end;

    obj._oldLFMDestroy = obj.destroy;

    function obj:destroy() 
        self:_releaseEvents();

        if (self.handle ~= 0) and (self.setNodeDatabase ~= nil) then
          self:setNodeDatabase(nil);
        end;

        if self.label1 ~= nil then self.label1:destroy(); self.label1 = nil; end;
        if self.button1 ~= nil then self.button1:destroy(); self.button1 = nil; end;
        if self.layout1 ~= nil then self.layout1:destroy(); self.layout1 = nil; end;
        self:_oldLFMDestroy();
    end;

    obj:endUpdate();

    return obj;
end;

function newfrmExportadorDePastas()
    local retObj = nil;
    __o_rrpgObjs.beginObjectsLoading();

    __o_Utils.tryFinally(
      function()
        retObj = constructNew_frmExportadorDePastas();
      end,
      function()
        __o_rrpgObjs.endObjectsLoading();
      end);

    assert(retObj ~= nil);
    return retObj;
end;

local _frmExportadorDePastas = {
    newEditor = newfrmExportadorDePastas, 
    new = newfrmExportadorDePastas, 
    name = "frmExportadorDePastas", 
    dataType = "com.tkplayer.extractor", 
    formType = "tablesDock", 
    formComponentName = "form", 
    cacheMode = "none", 
    title = "Exportador de Pastas", 
    description=""};

frmExportadorDePastas = _frmExportadorDePastas;
Firecast.registrarForm(_frmExportadorDePastas);
Firecast.registrarDataType(_frmExportadorDePastas);
Firecast.registrarSpecialForm(_frmExportadorDePastas);

return _frmExportadorDePastas;
