"use strict";
/**
 * Export all cloud functions.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.recommanderEntreprises = exports.genererRapportPeriodique = exports.predireRisqueRetard = exports.detectAnomalieDepenses = void 0;
// AI Module Functions
var detectAnomalieDepenses_1 = require("./ai/detectAnomalieDepenses");
Object.defineProperty(exports, "detectAnomalieDepenses", { enumerable: true, get: function () { return detectAnomalieDepenses_1.detectAnomalieDepenses; } });
var predireRisqueRetard_1 = require("./ai/predireRisqueRetard");
Object.defineProperty(exports, "predireRisqueRetard", { enumerable: true, get: function () { return predireRisqueRetard_1.predireRisqueRetard; } });
var genererRapportPeriodique_1 = require("./ai/genererRapportPeriodique");
Object.defineProperty(exports, "genererRapportPeriodique", { enumerable: true, get: function () { return genererRapportPeriodique_1.genererRapportPeriodique; } });
var recommanderEntreprises_1 = require("./ai/recommanderEntreprises");
Object.defineProperty(exports, "recommanderEntreprises", { enumerable: true, get: function () { return recommanderEntreprises_1.recommanderEntreprises; } });
//# sourceMappingURL=index.js.map