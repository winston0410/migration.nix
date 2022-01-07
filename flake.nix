{
  description = "Migration flake for running migration and seeding operation";

  outputs = { ... }:
    {
        postgres = let 
            setup = ''
                touch ./seed.sql
                mkdir -p ./migrations
                touch ./.env
            '';

            migration = ''
                source ./.env
                
                if [ "$POSTGRES_USER" == "" ]; then
                  POSTGRES_USER="postgres"
                fi
                
                if [ "$DATABASE_URL" == "" ]; then
                  DATABASE_URL="postgres://$POSTGRES_USER:$POSTGRES_PASSWORD@localhost/$DATABASE_NAME"
                fi
                
                dropdb --if-exists -f -U "$POSTGRES_USER" "$DATABASE_NAME"
                createdb -U postgres "$DATABASE_NAME"
            '';
            
            seed = ''
                psql -U postgres -d $DATABASE_NAME < ./seed.sql
            '';
        in {
            inherit setup migration seed;

            all = ''
                ${setup}
                ${migration}
                ${seed}
            '';
        };
    };
}
