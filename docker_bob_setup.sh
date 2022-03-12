counter=0
wait=1000
until $(curl --output /dev/null --silent --head --fail http://localhost:3001/api/authors) || [ $counter == $wait ]; do
    echo "Waiting on ACAS to start..."
    sleep 1
    counter=$((counter+1))
done
if [ $counter == $wait ]; then
    echo "waited $wait seconds for acas to start, giving up on prepare module conf json"
else
    # getOrCreateACASBob
    curl -i -X GET -H "Accept: application/json" http://localhost:3001/api/systemTest/getOrCreateACASBob
    # getOrCreateGlobalProject
    curl -i -X GET -H "Accept: application/json" http://localhost:3001/api/systemTest/getOrCreateGlobalProject
    # getOrCreateGlobalProjectRole
    curl -i -X GET -H "Accept: application/json" http://localhost:3001/api/systemTest/getOrCreateGlobalProjectRole
    # giveBobRoles
    curl -i -X GET -H "Accept: application/json" http://localhost:3001/api/systemTest/giveBobRoles
fi
