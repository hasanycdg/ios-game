"""Fictional Future 2050 scenarios for the United Kingdom and France.

Same structure as the German and US expansions: eight mandatory story
decisions per year (2026–2050) in three chapters, plus three optional domestic
events per year. 2030 step 2 is the escalation decision; 2050 step 8 is the
final settlement. Contexts are built from translatable templates so German and
French catalogs only need the templates, titles and choices.
"""

CHAPTERS = {
    "escalation": "crisis prevention and escalation",
    "reconstruction": "reconstruction and renewal",
    "worldOrder": "a new world order",
}


def chapter(year):
    return CHAPTERS["escalation"] if year <= 2034 else CHAPTERS["reconstruction"] if year <= 2042 else CHAPTERS["worldOrder"]


CONTEXT_TEMPLATE = "Fictional {0} scenario — {1}.\n\n{2}: {3}"
CONTEXT_SUFFIX = " Your earlier choices determine the resources and public support available now. Whether earlier crises were contained or escalated, this decision shapes what comes next."

UK_FUTURE = """
2026|A European security pact after Brexit|Patrolling undersea cables in the North Sea|A sovereign AI and chip strategy|Grid connections for offshore wind|An NHS winter that never ends|Online safety and age verification|A ten-year defence and resilience budget|A new settlement for the nations of the UK
2027|Russian shadow fleets in the Channel|Rebuilding the Royal Navy's escorts|Ports, tariffs and Atlantic trade|A storm surge on the east coast|The social care cliff edge|A ransomware attack on hospitals|A crisis in local council finances|A second Scottish referendum demand
2028|A Nordic and Baltic defence summit|Air defence for British cities|Critical minerals and battery factories|Small modular reactors|A new vaccine manufacturing base|Deepfakes in a general election campaign|Paying for rearmament|Reform of the House of Lords
2029|An arms-control treaty collapses|A standoff in the High North|A shipping insurance shock|Protecting offshore energy platforms|Mental health care for veterans|GPS jamming over British airspace|Gilt markets test the government|Emergency powers and Parliament
2030|Incursions on NATO's eastern flank|Britain's answer to the crisis|Shortages in British supply chains|Gas storage before a hard winter|Emergency medicine stockpiles|A nationwide communications outage|Paying for a prolonged crisis|Civil liberties during a security emergency
2031|A crisis hotline with Moscow|De-escalation or mobilisation|Converting factories to defence production|Black-start capacity for the grid|Hospital surge staffing|Cyber rules with rival powers|Oversight of emergency procurement|A national unity government debate
2032|An international ceasefire conference|Peace monitors and verification teams|Reopening European trade routes|Rebuilding damaged interconnectors|Treating displaced civilians|Restoring trusted communications|An emergency reconstruction fund|A parliamentary mandate for peace
2033|Security guarantees after the crisis|Transparency about nuclear stockpiles|Veteran-owned small businesses|Retiring fragile fossil infrastructure|Long-term trauma care|An international cyber incident register|The future of emergency powers|A public inquiry into crisis decisions
2034|A durable European settlement|A new defence posture|Restoring confidence in the City|A North Sea clean-energy partnership|Health security across borders|Civilian control of military AI|Ending extraordinary borrowing|A truth and reconciliation commission
2035|A reconstruction partnership with Europe|Clearing unexploded ordnance|Reviving former industrial towns|Power for recovering communities|Rebuilding community clinics|A public digital reconstruction platform|Who pays for reconstruction?|Returning emergency powers to Parliament
2036|Refugee resettlement agreements|Resilient emergency shelters|Training the reconstruction workforce|Repairing water and sewage systems|Accessible rehabilitation services|Digital identity with privacy rights|Auditing recovery contracts|Devolving recovery to the regions
2037|Debt relief for fragile partners|Protecting humanitarian routes|Restoring credit for small firms|Drought and flooding in a warmer Britain|Care for an ageing population|Gigabit broadband for rebuilding towns|Sharing recovery costs with the nations|Local voices in reconstruction
2038|An international rebuilding bank|Reserve forces for disaster response|A new advanced-manufacturing corridor|Clean heat for low-income homes|Rebuilding the public-health workforce|Open technical standards for recovery|Reconstruction taxes or borrowing?|A national service compact
2039|Rebuilding trust with former rivals|Independent security inspections|Competition in reconstruction markets|Rivers, reservoirs and flood defences|Mental health care in every town|A secure public-service cloud|Funding anti-corruption enforcement|Affordable homes in rebuilt communities
2040|A new partnership with the European Union|Joint emergency exercises with Europe|The next generation of British industry|Modernising the electricity market|Paying for long-term care|Public control of essential data|A sustainable post-crisis budget|A national conversation on inequality
2041|A global health-security compact|A review of civil contingencies|Diversifying coastal economies|Restoring damaged ecosystems|A new rural health workforce|Human review of automated benefits|Funding maintenance after reconstruction|The rights of displaced citizens
2042|A reconstruction legacy summit|Balancing defence and relief|From recovery subsidies to lasting jobs|Energy security without isolation|The future of the NHS|Closing the digital divide|An independent reconstruction audit|Codifying the constitution
2043|Reforming international institutions|A treaty on autonomous weapons|A new global trading framework|Sharing clean-energy technology|An international pandemic reserve|Democratic governance of advanced AI|Financing global public goods|Representation in a changed Britain
2044|A Commonwealth partnership for the future|Security guarantees for smaller states|Fair competition in AI-driven markets|A European supergrid agreement|A national care guarantee|The rights of people affected by AI|A new tax settlement|The integrity of the next election
2045|A permanent peace-verification body|Nuclear risk reduction|Worker ownership in automated industries|A national climate-adaptation standard|Lifelong health and disability cover|Public-interest computing capacity|A long-term debt and investment rule|Votes at sixteen and electoral reform
2046|Climate migration agreements|Community emergency reserves|Prosperity beyond London and the South East|Water sharing in a hotter summer|A national prevention strategy|A legal right to privacy|Fairness between generations in tax|Healing the divide between town and city
2047|Rules for strategic competition|Accountability for security contractors|The future of British entrepreneurship|A just transition for energy workers|A deal for family carers|Human responsibility for AI decisions|Pensions in a changing workforce|Citizenship education for the next generation
2048|A global charter on technology and rights|Protecting democratic infrastructure|Sharing productivity gains|A reliable zero-carbon power system|Equal access to advanced medicine|Auditing national digital infrastructure|The next fifty years of public investment|The future of the Union
2049|The future of Britain's alliances|A final strategic defence review|Preparing the next economic generation|A national resilience dividend|Health capacity for the next crisis|A public archive of algorithmic decisions|Closing emergency-era liabilities|A citizens' assembly on the national legacy
2050|Britain and the new world order|A lasting security settlement|The prosperity your choices created|The energy system of your Britain|The health of the next generation|Technology in the service of democracy|The fiscal legacy of your governments|Your Britain in 2050
"""

FR_FUTURE = """
2026|A European defence union|Protecting French overseas territories|A sovereign AI and chip strategy|Building the new EPR2 reactors|Emergency departments under strain|Protecting minors online|A ten-year defence and resilience budget|A new pact with the regions
2027|Drones over military bases|Rebuilding ammunition stocks|Reindustrialising France|A Mediterranean heatwave and wildfires|Medical deserts in rural France|A ransomware attack on hospitals|Debt markets test the Republic|Institutional deadlock after the elections
2028|A summit on Europe's nuclear umbrella|Air defence for French cities|Critical minerals and battery gigafactories|Small modular reactors|A European vaccine reserve|Deepfakes in an election campaign|Paying for rearmament|Proportional representation for the Assemblée
2029|An arms-control treaty collapses|Instability across the Sahel|A shipping insurance shock|Protecting undersea cables and pipelines|Mental health care for veterans|GPS jamming over French airspace|A sovereign debt downgrade|Emergency powers and parliamentary control
2030|Incursions on NATO's eastern flank|France's answer to the crisis|Shortages in French supply chains|Gas storage before a hard winter|Emergency medicine stockpiles|A nationwide communications outage|Paying for a prolonged crisis|Civil liberties during a security emergency
2031|A crisis hotline with Moscow|De-escalation or mobilisation|A war economy for defence production|Black-start capacity for the grid|Hospital surge staffing|Cyber rules with rival powers|Oversight of emergency procurement|A government of national unity
2032|A ceasefire conference in Geneva|Peace monitors and verification teams|Reopening European trade routes|Rebuilding damaged interconnectors|Treating displaced civilians|Restoring trusted communications|A European reconstruction fund|A parliamentary mandate for peace
2033|Security guarantees after the crisis|Transparency about nuclear stockpiles|Veteran-owned small businesses|Retiring fragile fossil infrastructure|Long-term trauma care|An international cyber incident register|Ending the state of emergency|A commission of inquiry into crisis decisions
2034|A durable European settlement|A new defence posture|Restoring investor confidence|A Franco-German energy partnership|Health security across borders|Civilian control of military AI|Ending extraordinary borrowing|A truth and reconciliation commission
2035|A reconstruction partnership with Europe|Clearing unexploded ordnance|Reviving industrial towns|Power for recovering communities|Rebuilding local health centres|A public digital reconstruction platform|Who pays for reconstruction?|Returning emergency powers to Parliament
2036|Refugee resettlement agreements|Resilient emergency shelters|Training the reconstruction workforce|Repairing water networks|Accessible rehabilitation services|Digital identity with privacy rights|Auditing recovery contracts|Decentralising recovery to the regions
2037|Debt relief for fragile partners|Protecting humanitarian corridors|Restoring credit for small firms|Drought and water in the south|Care for an ageing population|Fibre broadband for rebuilding towns|Sharing recovery costs with local authorities|Citizens' voices in reconstruction
2038|An international rebuilding bank|Reservists for disaster response|A new advanced-manufacturing corridor|Clean heat for low-income homes|Rebuilding the public-health workforce|Open technical standards for recovery|Reconstruction taxes or borrowing?|A universal national service
2039|Rebuilding trust with former rivals|Independent security inspections|Competition in reconstruction markets|Rivers, dams and flood defences|Mental health care in every department|A sovereign public-service cloud|Funding anti-corruption enforcement|Affordable housing in rebuilt communities
2040|A new Franco-German treaty|Joint emergency exercises in Europe|The next generation of French industry|Reforming the European electricity market|Financing long-term care|Public control of essential data|A sustainable post-crisis budget|A national debate on inequality
2041|A global health-security compact|A review of civil protection|Diversifying coastal and mountain economies|Restoring damaged ecosystems|A new rural health workforce|Human review of automated benefits|Funding maintenance after reconstruction|The rights of displaced citizens
2042|A reconstruction legacy summit|Balancing defence and relief|From recovery subsidies to lasting jobs|Energy sovereignty without isolation|The future of the hospital system|Closing the digital divide|An independent reconstruction audit|A Sixth Republic debate
2043|Reforming international institutions|A treaty on autonomous weapons|A new global trading framework|Sharing clean-energy technology|An international pandemic reserve|Democratic governance of advanced AI|Financing global public goods|Representation in a changed France
2044|A partnership with Africa for the future|Security guarantees for smaller states|Fair competition in AI-driven markets|A European supergrid agreement|A national dependency-care guarantee|The rights of people affected by AI|A new tax settlement|The integrity of the next election
2045|A permanent peace-verification body|Nuclear risk reduction|Worker ownership in automated industries|A national climate-adaptation standard|Lifelong health and disability cover|Public-interest computing capacity|A long-term debt and investment rule|A citizens' initiative referendum
2046|Climate migration agreements|Local emergency reserves|Prosperity beyond Paris|Water sharing in hotter summers|A national prevention strategy|A constitutional right to privacy|Fairness between generations in tax|Healing the divide between cities and the countryside
2047|Rules for strategic competition|Accountability for security contractors|The future of French entrepreneurship|A just transition for energy workers|A deal for family carers|Human responsibility for AI decisions|Pensions in a changing workforce|Civic education and secularism for the next generation
2048|A global charter on technology and rights|Protecting democratic infrastructure|Sharing productivity gains|A reliable low-carbon power system|Equal access to advanced medicine|Auditing national digital infrastructure|The next fifty years of public investment|The future of the overseas territories
2049|The future of France's alliances|A final defence and security white paper|Preparing the next economic generation|A national resilience dividend|Health capacity for the next crisis|A public archive of algorithmic decisions|Closing emergency-era liabilities|A citizens' convention on the national legacy
2050|France and the new world order|A lasting security settlement|The prosperity your choices created|The energy system of your France|The health of the next generation|Technology in the service of democracy|The fiscal legacy of your governments|Your France in 2050
"""

UK_PORTFOLIOS = [
    ("foreignPolicy", "Allies and partners ask London for a durable agreement. A wider commitment could strengthen cooperation, but MPs question its cost and the limits on British freedom of action.", "Fund a sustained diplomatic and allied initiative", "Negotiate a limited, verifiable agreement", "Reduce new international commitments"),
    ("security", "The armed forces and civilian agencies disagree about readiness, escalation risks and oversight. Parliament demands a plan that protects the country without creating an open-ended emergency.", "Fund accountable readiness and civilian protection", "Pair a limited security response with de-escalation", "Limit new security commitments"),
    ("economy", "British employers and workers face another structural adjustment. Public investment could build new capacity, while critics warn of costly subsidies and favouritism.", "Invest in domestic capacity and worker transition", "Offer targeted support with performance conditions", "Leave most investment decisions to private markets"),
    ("energy", "Energy suppliers, the devolved governments and households want reliable, affordable energy and stronger protection against disruption. A national programme could accelerate progress but requires substantial funding.", "Fund a national clean-energy and resilience programme", "Negotiate regional upgrades and targeted incentives", "Rely on investment by energy companies"),
    ("welfare", "The NHS, councils and families report gaps in care. The government can expand capacity, negotiate a narrower safety net or leave the adjustment to existing providers.", "Fund nationwide care capacity and affordable access", "Target help at the most vulnerable communities", "Limit new care commitments"),
    ("digitalization", "New technology promises better services but raises questions about security, privacy and accountability. Whitehall needs rules that can survive the next change of government.", "Fund independent oversight and secure public infrastructure", "Pilot standards with transparent evaluation", "Favour voluntary standards and private development"),
    ("budget", "The Treasury presents competing demands on public money. Ministers must balance lasting investment, reliable services and the burden placed on future taxpayers.", "Finance a durable investment and revenue settlement", "Phase in a narrower cross-party fiscal agreement", "Prioritise immediate spending cuts and private provision"),
    ("society", "The nations, councils and community groups disagree about the next national settlement. The decision will shape trust, participation and the balance between Westminster and local power.", "Fund a broad rights and community-investment initiative", "Negotiate a focused cross-party agreement", "Leave further action mainly to councils and communities"),
]

FR_PORTFOLIOS = [
    ("foreignPolicy", "Allies and partners ask Paris for a durable agreement. A wider commitment could strengthen cooperation, but parliament questions its cost and the limits on French strategic autonomy.", "Fund a sustained diplomatic and allied initiative", "Negotiate a limited, verifiable agreement", "Reduce new international commitments"),
    ("security", "The armed forces and civilian services disagree about readiness, escalation risks and oversight. Parliament demands a plan that protects the country without creating an open-ended emergency.", "Fund accountable readiness and civilian protection", "Pair a limited security response with de-escalation", "Limit new security commitments"),
    ("economy", "French employers and workers face another structural adjustment. State investment could build new capacity, while critics warn of costly subsidies and favouritism.", "Invest in domestic capacity and worker transition", "Offer targeted support with performance conditions", "Leave most investment decisions to private markets"),
    ("energy", "The grid operator, the regions and households want reliable, affordable energy and stronger protection against disruption. A national programme could accelerate progress but requires substantial funding.", "Fund a national low-carbon energy and resilience programme", "Negotiate regional upgrades and targeted incentives", "Rely on investment by energy companies"),
    ("welfare", "Hospitals, local authorities and families report gaps in care. The government can expand capacity, negotiate a narrower safety net or leave the adjustment to existing providers.", "Fund nationwide care capacity and affordable access", "Target help at the most vulnerable communities", "Limit new care commitments"),
    ("digitalization", "New technology promises better services but raises questions about security, privacy and accountability. The state needs rules that can survive the next change of government.", "Fund independent oversight and secure public infrastructure", "Pilot standards with transparent evaluation", "Favour voluntary standards and private development"),
    ("budget", "The finance ministry presents competing demands on public money. The government must balance lasting investment, reliable services and the burden placed on future taxpayers.", "Finance a durable investment and revenue settlement", "Phase in a narrower negotiated fiscal agreement", "Prioritise immediate spending cuts and private provision"),
    ("society", "The regions, mayors and civil society disagree about the next national pact. The decision will shape trust, participation and the balance between Paris and local power.", "Fund a broad rights and community-investment initiative", "Negotiate a focused agreement across parties", "Leave further action mainly to local authorities"),
]

# Optional domestic events: (category, title template, context template, three choices).
UK_EXTRAS = [
    ("welfare", "Local care services ({0})", "Fictional {0} domestic scenario. Councils ask the government for help with local care services that fit the national path you have chosen.",
     ["Fund a national programme for local care services", "Negotiate targeted matching grants for care services", "Leave additional financing to councils and private providers"]),
    ("economy", "Small-business recovery ({0})", "Fictional {0} domestic scenario. High streets and small firms ask the government for help to recover and grow.",
     ["Fund a national programme for small-business recovery", "Negotiate targeted matching grants for small firms", "Leave additional financing to banks and private investors"]),
    ("energy", "Community resilience ({0})", "Fictional {0} domestic scenario. Towns and villages ask for help to protect homes and services against storms, floods and outages.",
     ["Fund a national community resilience programme", "Negotiate targeted matching grants for resilience", "Leave additional financing to councils and utilities"]),
]

FR_EXTRAS = [
    ("welfare", "Local care services ({0})", "Fictional {0} domestic scenario. Departments and mayors ask the state for help with local care services that fit the national path you have chosen.",
     ["Fund a national programme for local care services", "Negotiate targeted co-financing for care services", "Leave additional financing to local authorities and private providers"]),
    ("economy", "Small-business recovery ({0})", "Fictional {0} domestic scenario. Town centres, artisans and small firms ask the state for help to recover and grow.",
     ["Fund a national programme for small-business recovery", "Negotiate targeted co-financing for small firms", "Leave additional financing to banks and private investors"]),
    ("energy", "Community resilience ({0})", "Fictional {0} domestic scenario. Communes ask for help to protect homes and services against heatwaves, floods and outages.",
     ["Fund a national community resilience programme", "Negotiate targeted co-financing for resilience", "Leave additional financing to communes and utilities"]),
]


def build(code, table, portfolios, extras):
    events = []
    for line in table.strip().splitlines():
        year_text, *titles = line.split("|")
        year = int(year_text)
        assert len(titles) == 8, year
        for step, (title, portfolio) in enumerate(zip(titles, portfolios), start=1):
            category, context, *choices = portfolio
            events.append(dict(
                id=f"future-scenario-{code}-{year}-{step}", year=year, category=category, title=title,
                context=CONTEXT_TEMPLATE.format(year, chapter(year), title, context + CONTEXT_SUFFIX),
                choices=choices, reality=None, source=None, historicalChoice=None, shock=None, step=step))
        for index, (category, title, context, choices) in enumerate(extras):
            events.append(dict(
                id=f"future-{code}-extra-{year}-{index}", year=year, category=category,
                title=title.format(year), context=context.format(year), choices=choices,
                reality=None, source=None, historicalChoice=None, shock=None, step=None))
    assert len(events) == 275
    return events


def translatable(table, portfolios, extras):
    """English strings and templates that need German and French translations."""
    texts = set(CHAPTERS.values())
    for line in table.strip().splitlines():
        texts.update(line.split("|")[1:])
    for category, context, *choices in portfolios:
        texts.add("Fictional {0} scenario — {1}.\n\n{2}: " + context + CONTEXT_SUFFIX)
        texts.update(choices)
    for category, title, context, choices in extras:
        texts.update([title, context, *choices])
    return sorted(texts)
