counter=0
wait=300
until $(curl --output /dev/null --silent --head --fail http://localhost:3001/api/authors) || [ $counter == $wait ]; do
    if [ $counter == 0 ]; then
        echo "Waiting for ACAS API to start..."
    fi
    sleep 1
    remaining=$((wait - counter))
    echo "Waiting for ACAS API to start...remaining attempts: $remaining"
    counter=$((counter+1))
done
if [ $counter == $wait ]; then
    echo "waited $wait seconds for acas to start, giving up"
else
    echo "ACAS started!"
    # getOrCreateACASBob
    curl --max-time 5 -i -X GET -H "Accept: application/json" http://localhost:3001/api/systemTest/getOrCreateACASBob
    # getOrCreateGlobalProject
    curl --max-time 5 -i -X GET -H "Accept: application/json" http://localhost:3001/api/systemTest/getOrCreateGlobalProject
    # getOrCreateGlobalProjectRole
    curl --max-time 5 -i -X GET -H "Accept: application/json" http://localhost:3001/api/systemTest/getOrCreateGlobalProjectRole
    # giveBobRoles
    curl --max-time 5 -i -X GET -H "Accept: application/json" http://localhost:3001/api/systemTest/giveBobRoles
fi
