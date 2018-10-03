with MAPPING_IDS as (
    select distinct cr1.concept_id_1 CONCEPT_ID,
		CONCAT('Has relation to descendant of : ', RELATIONSHIP_NAME) RELATIONSHIP_NAME,
		min_levels_of_separation RELATIONSHIP_DISTANCE,
		cr1.RELATIONSHIP_ID CR_RELATIONSHIP_ID,
		cr1.INVALID_REASON CR_INVALID_REASON
	from @CDM_schema.concept_ancestor ca1
	join @CDM_schema.concept_relationship cr1 on ca1.descendant_concept_id = cr1.concept_id_2
	join @CDM_schema.relationship r on r.relationship_id = cr1.relationship_id
	where ca1.ancestor_concept_id = @id
)
select distinct C.CONCEPT_ID,
    CONCEPT_NAME,
    ISNULL(STANDARD_CONCEPT,'N') STANDARD_CONCEPT,
    ISNULL(c.INVALID_REASON,'V') INVALID_REASON,
    CONCEPT_CODE,
    CONCEPT_CLASS_ID,
    DOMAIN_ID,
    VOCABULARY_ID,
    RELATIONSHIP_NAME,
    RELATIONSHIP_DISTANCE
from (
	select cr.CONCEPT_ID_2 CONCEPT_ID, RELATIONSHIP_NAME, 1 RELATIONSHIP_DISTANCE
	from @CDM_schema.CONCEPT_RELATIONSHIP cr
	join @CDM_schema.CONCEPT c on cr.CONCEPT_ID_2 = c.CONCEPT_ID
	join @CDM_schema.RELATIONSHIP r on cr.RELATIONSHIP_ID = r.RELATIONSHIP_ID
	where cr.CONCEPT_ID_1 = @id and cr.INVALID_REASON IS NULL
union
	select ANCESTOR_CONCEPT_ID CONCEPT_ID, 'Has ancestor of' RELATIONSHIP_NAME, MIN_LEVELS_OF_SEPARATION RELATIONSHIP_DISTANCE
	from @CDM_schema.CONCEPT_ANCESTOR ca
	where DESCENDANT_CONCEPT_ID = @id
	and ANCESTOR_CONCEPT_ID <> @id
union
	select DESCENDANT_CONCEPT_ID, 'Has descendant of' RELATIONSHIP_NAME, MIN_LEVELS_OF_SEPARATION RELATIONSHIP_DISTANCE
	from @CDM_schema.CONCEPT_ANCESTOR ca
	join @CDM_schema.CONCEPT c on c.CONCEPT_ID = ca.DESCENDANT_CONCEPT_ID
	where ANCESTOR_CONCEPT_ID = @id
	and DESCENDANT_CONCEPT_ID <> @id
union
	select CONCEPT_ID, RELATIONSHIP_NAME, RELATIONSHIP_DISTANCE
	from MAPPING_IDS
    where CR_RELATIONSHIP_ID = 'Maps to' and CR_INVALID_REASON IS NULL
) ALL_RELATED
JOIN CONCEPT C on ALL_RELATED.CONCEPT_ID = C.CONCEPT_ID
order by RELATIONSHIP_DISTANCE ASC