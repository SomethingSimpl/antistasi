#include "../macros.hpp"
params ["_unit", "_arsenal"];

[_unit] call AS_fnc_emptyUnit;
_unit call AS_fnc_equipDefault;

_unit forceAddUniform (selectRandom (["FIA", "uniforms"] call AS_fnc_getEntity));

_arsenal params ["_vest", "_helmet", "_googles", "_backpack",
    "_primaryWeapon", "_primaryMags", "_secondaryWeapon",
    "_secondaryMags", "_scope", "_items", "_primaryWeaponItems"
];

private _fnc_equipUnit = {
    params ["_weapon", "_mags"];
    if (_weapon != "") then {
        [_unit, _weapon, 0, 0] call BIS_fnc_addWeapon;

        for "_i" from 0 to (count (_mags select 0) - 1) do {
            private _name = (_mags select 0) select _i;
            private _amount = (_mags select 1) select _i;
            _unit addMagazines [_name, _amount];
        };
    };
};

if (_vest != "") then {
    _unit addVest _vest;
};

if (_helmet != "") then {
    _unit addHeadgear _helmet;
};

if (_googles != "") then {
    _unit linkItem _googles;
};

if (_backpack != "") then {
    _unit addBackpackGlobal _backpack;
};

[_primaryWeapon, _primaryMags] call _fnc_equipUnit;
[_secondaryWeapon, _secondaryMags] call _fnc_equipUnit;

// add items
private _i = 0;
while {_i < count _items} do {
    private _item = (_items select _i) select 0;
    private _amount = (_items select _i) select 1;

    private _j = 0;
    while {_j < _amount} do {
        if (_unit canAdd _item) then {
            _unit addItem _item;
        };
        _j = _j + 1;
    };
    _i = _i + 1;
};

if (_scope != "") then {
    _unit addPrimaryWeaponItem _scope;
};

{
    _unit addPrimaryWeaponItem _x;
} forEach _primaryWeaponItems;

// remove from box stuff that was used.
private _cargo = [_unit, true] call AS_fnc_getUnitArsenal;
waitUntil {not AS_S("lockTransfer")};
AS_Sset("lockTransfer", true);
([caja] call AS_fnc_getBoxArsenal) params ["_cargo_w", "_cargo_m", "_cargo_i", "_cargo_b"];
private _cargo_w = [_cargo_w, _cargo select 0, false] call AS_fnc_mergeCargoLists;
private _cargo_m = [_cargo_m, _cargo select 1, false] call AS_fnc_mergeCargoLists;
private _cargo_i = [_cargo_i, _cargo select 2, false] call AS_fnc_mergeCargoLists;
private _cargo_b = [_cargo_b, _cargo select 3, false] call AS_fnc_mergeCargoLists;
[caja, _cargo_w, _cargo_m, _cargo_i, _cargo_b, true, true] call AS_fnc_populateBox;
AS_Sset("lockTransfer", false);

_unit selectWeapon (primaryWeapon _unit);
