//From which source come the addresses, which have the country property? -> SourceID="Paradise Papers - Malta corporate registry"
MATCH (a:Address)
WHERE a.country IS NOT null
RETURN DISTINCT a.sourceID

//to find some people with addresses in Munich via zip code; 
//only works for addresses with property .country and the zip code needs to be at the end; 
//also often the zip code is not part of the address property but instead of the name property
MATCH (o:Officer) -[c*1..2]- (a:Address)
WITH *, toInteger(right(a.address, 5)) AS plz_de
WHERE a.country = "Germany" AND (plz_de >= 80000 AND plz_de < 82000)
RETURN o.name, count(o.name) AS num_of_appearances
 ORDER BY o.name

//node link distribution
MATCH p=()-[r]-()
RETURN r.link, count(r.link) AS num
 ORDER BY num desc

//get degree of every node
MATCH (n)
RETURN DISTINCT ID(n), size((n)--()) AS degree
 ORDER BY degree DESC
LIMIT 5

//How many officers and entities contains each database/source?
CALL{
  MATCH (n:Officer)
  RETURN n.sourceID AS source, "Officer" AS label, count(n) AS num
  UNION
  MATCH (n:Entity)
  RETURN n.sourceID AS source, "Entity" AS label, count(n) AS num
}
RETURN source, label, num
 ORDER BY source, num
//Yields the same results as
MATCH (n)
WITH *, labels(n) AS label
WHERE "Officer" IN label OR "Entity" IN label
RETURN n.sourceID AS source, label, count(n) AS num
 ORDER BY source, num

//Are there addresses used by multiple entities? -> Yes
MATCH (a:Address)--(e:Entity)
WITH *, size((a)--(e)) AS num_rel
WHERE num_rel > 1
RETURN a.address, num_rel

//Where are the addresses located? -> everywhere
//(country or countries)?
//-> country clean; 193 distinct values;
//-> countries unclean; ~365 different values, incl. country codes, multiple countries put together, etc.
//-> coutnries does exist too, but seems to be empty everywhere
MATCH (a:Address)
RETURN DISTINCT a.country AS country
//Or:
CALL{
  MATCH (a:Address)
  RETURN DISTINCT a.country AS country
  UNION
  MATCH (b:Address)
RETURN DISTINCT b.countries AS country}
RETURN country
 ORDER BY country

//What constellations are there for german addresses? (for simplification: country is clean; coutnries empty)
MATCH (a:Address)
WHERE a.country = "Germany" OR a.countries CONTAINS "Germany" OR a.countries CONTAINS "DEU" OR toLower(a.country_code) CONTAINS "deu" OR toLower(a.country_codes) CONTAINS "deu"
RETURN DISTINCT a.country, a.countries, a.country_code, a.country_codes

//are we still missing some because the country is set wrongly? -> yes, apparently (the one in NL and possibly more which do not contain germany in the address; why does the british one contains Germany in its address?)
//union is needed, because a <> comparison with null doesn't evaluate to true
MATCH (a:Address)
WHERE a.country <> "Germany" AND toLower(a.address) CONTAINS "germany"
RETURN DISTINCT a.address, a.country, a.countries, a.country_code, a.country_codes
UNION
MATCH (a:Address)
WHERE a.country_codes <> "DEU" AND toLower(a.address) CONTAINS "germany"
RETURN DISTINCT a.address, a.country, a.countries, a.country_code, a.country_codes

//Is there information about the same entity(ies)/officer(s) in multiple databases? -> Yes
MATCH (o:Officer)-[r]-(n)
WHERE o.sourceID <> n.sourceID
RETURN DISTINCT o.name AS Officer, o.sourceID AS OfficerSource, n.name AS Connection, n.sourceID AS ConnectionSource

//Does each entity/officer have a connection? -> no, 358 do not
MATCH (n)
WHERE NOT exists((n)--())
RETURN count(n)

//Which are the officers/entities with the most connections?
//Address connected to most other nodes
//for Officers
MATCH (a:Officer)
WITH max(size((a)--())) AS max_num_rel

MATCH (b:Officer)--()
WITH *, size((b)--()) AS num_rel //==degree
WHERE num_rel = max_num_rel
RETURN DISTINCT b.name, num_rel

//for Entities
MATCH (a:Entity)
WITH max(size((a)--())) AS max_num_rel

MATCH (b:Entity)--()
WITH *, size((b)--()) AS num_rel //==degree
WHERE num_rel = max_num_rel
RETURN DISTINCT b.name, num_rel

//in theory the following should work, however it takes too much time to execute
//length of longest path in network
CALL{
  MATCH p=((n1)-[*..]-(n2))
RETURN DISTINCT p AS con_comp}
RETURN length(con_comp) AS long_path
 ORDER BY long_path desc
LIMIT 1

//but we can get a connected component with paths of length 3000 or longer:
//although my laptop already struggles a little bit with it
MATCH p=((n1)-[*3000..]-(n2))
RETURN DISTINCT p AS con_comp
LIMIT 1

//Are there cycles in the networks? How would you interpret this? -> Yes, but apparently only for entities
MATCH p=((n1)-[*3]->(n1))
RETURN DISTINCT p
LIMIT 200

//but those cycles only describe related entities:
MATCH p=((n1)-[r*3]->(n1))
WITH r AS cons

UNWIND cons AS r
CALL {
  WITH r
RETURN DISTINCT r.link AS link }
RETURN DISTINCT link
