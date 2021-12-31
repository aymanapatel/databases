select name, artist, text from card

select name, artist, text
from card
where to_tsvector(name) @@ to_tsquery('Wall'); ---<----- search in name with lexeme 'Wall'


-------------
SELECT to_tsquery('english', 'Fat | Rats:AB');

select to_tsquery('Wall');

----

select name, artist, text
from card
where to_tsvector(name || ' ' || text) @@ to_tsquery('Wall'); 
----^---- search in name and text with lexeme 'Wall'
-------- || is Appending operator in Postgres

select name, artist, text
from card
where to_tsvector(name || ' ' || artist || ' ' || text) @@ to_tsquery('Avon');


--v--- ADD column document of type tsvector. docment will combine vector for name, artist and text
ALTER TABLE card
  ADD COLUMN document tsvector;
update card
set document = to_tsvector(name || ' ' || artist || ' ' || text);


--v--- Querying using document vector we created in last script
select name, artist, text
from card
where document @@ to_tsquery('Avon');



-- Execution Time: 23s
explain analyze select name, artist, text
                from card
                where to_tsvector(name || ' ' || artist || ' ' || text) @@ to_tsquery('Avon');
-- Execution Time: 1.5s
explain analyze select name, artist, text
                from card
                where document @@ to_tsquery('Avon');
               

ALTER TABLE card
  ADD COLUMN document_with_idx tsvector;
update card
set document_with_idx = to_tsvector(name || ' ' || artist || ' ' || coalesce(text, '')); -- coales

select name, artist, text
from card
where document_with_idx @@ to_tsquery('Avon');
               
               
CREATE INDEX document_idx
  ON card
  USING GIN (document_with_idx); 
---^---------- GIN are useful when an index must map many values to one row, 
-------------- whereas B-Tree indexes are optimized for when a row has a single key value. 
-------------- GINs are good for indexing array values as well as for implementing full-text search. 

 
-- Execution Time: 1.5s 
explain analyze select name, artist, text
                from card
                where document @@ to_tsquery('Avon');
-- Execution Time: 0.120s
explain analyze select name, artist, text
                from card
                where document_with_idx @@ to_tsquery('Avon');
               
               

---- Rank select queries based on ts-rank
select name, artist, text
from card
where document_with_idx @@ plainto_tsquery('Avon')
order by ts_rank(document_with_idx, plainto_tsquery('Avon')); --- ts_rank


ALTER TABLE card
  ADD COLUMN document_with_weights tsvector;
update card
set document_with_weights = setweight(to_tsvector(name), 'A') ||
  setweight(to_tsvector(artist), 'B') ||
    setweight(to_tsvector(coalesce(text, '')), 'C');
CREATE INDEX document_weights_idx
  ON card
  USING GIN (document_with_weights);

select name, artist, text
from card
where document_with_weights @@ plainto_tsquery('island')
order by ts_rank(document_with_weights, plainto_tsquery('island')) desc;

select name, artist, text, ts_rank(document_with_weights, plainto_tsquery('island'))
from card
where document_with_weights @@ plainto_tsquery('island')
order by ts_rank(document_with_weights, plainto_tsquery('island')) desc;

CREATE FUNCTION card_tsvector_trigger() RETURNS trigger AS $$
begin
  new.document :=
  setweight(to_tsvector('english', coalesce(new.name, '')), 'A')
  || setweight(to_tsvector('english', coalesce(new.artist, '')), 'B')
  || setweight(to_tsvector('english', coalesce(new.text, '')), 'C');
  return new;
end
$$ LANGUAGE plpgsql;

CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
    ON card FOR EACH ROW EXECUTE PROCEDURE card_tsvector_trigger();
